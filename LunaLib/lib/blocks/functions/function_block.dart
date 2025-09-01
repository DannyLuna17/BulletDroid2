import 'dart:convert';
import 'dart:math';
import '../base/block_instance.dart';
import '../../core/bot_data.dart';
import '../../parsing/interpolation_engine.dart';
import '../../variables/variable_factory.dart';
import '../../variables/variable.dart';
import '../../variables/variable_types.dart';
import '../../parsing/line_parser.dart';
import '../../functions/crypto_helper.dart';
import 'package:math_expressions/math_expressions.dart';

enum FunctionType {
  constant,
  base64Encode,
  base64Decode,
  hash,
  hmac,
  translate,
  dateToUnixTime,
  length,
  toLowercase,
  toUppercase,
  replace,
  regexMatch,
  urlEncode,
  urlDecode,
  unescape,
  htmlEntityEncode,
  htmlEntityDecode,
  unixTimeToDate,
  currentUnixTime,
  unixTimeToISO8601,
  randomNum,
  randomString,
  ceil,
  floor,
  round,
  compute,
  countOccurrences,
  clearCookies,
  rsaEncrypt,
  rsaPKCS1PAD2,
  delay,
  charAt,
  substring,
  reverseString,
  trim,
  getRandomUA,
  aesEncrypt,
  aesDecrypt,
  pbkdf2PKCS5,
  generateGUID
}

class FunctionBlock extends BlockInstance {
  String functionName = '';
  String inputString = '';
  String outputVariable = '';
  bool isCapture = false;
  String _labelText = '';

  Map<String, dynamic> parameters = {};

  FunctionBlock() : super(id: 'Function');

  @override
  String get label => _labelText;

  @override
  Future<void> execute(BotData data) async {
    try {
      // Check if input string contains List variable reference
      final listMatch =
          RegExp(r'<([A-Za-z_][A-Za-z0-9_]*)\[\*\]>').firstMatch(inputString);

      if (listMatch != null) {
        final listVarName = listMatch.group(1)!;
        final listVariable = data.variables.get(listVarName);

        if (listVariable != null &&
            listVariable.type == VariableType.ListOfStrings) {
          final listVar = listVariable as ListVariable;
          final results = <String>[];

          // Execute function on each element
          for (final element in listVar.value) {
            // Replace <VAR[*]> with current element in input string
            final processedInput =
                inputString.replaceAll('<${listVarName}[*]>', element);
            final interpolatedInput = InterpolationEngine.interpolate(
                processedInput, data.variables, data);
            final result =
                await _executeFunction(functionName, interpolatedInput, data);
            results.add(result);
          }

          // Set output variable as List if specified
          if (outputVariable.isNotEmpty) {
            final variable =
                VariableFactory.fromObject(outputVariable, results);
            data.variables.set(variable);

            if (isCapture) {
              data.variables.markForCapture(outputVariable);
            }

            data.log(
                'FUNCTION $functionName: Set List $outputVariable with ${results.length} elements');
          }

          return;
        }
      }

      // Regular execution for non-List variables
      final shouldInterpolate = !['HTMLENTITYENCODE', 'HTMLENTITYDECODE']
          .contains(functionName.toUpperCase());
      final processedInput = shouldInterpolate
          ? InterpolationEngine.interpolate(inputString, data.variables, data)
          : inputString;

      final result = await _executeFunction(functionName, processedInput, data);

      // Set output variable if specified
      if (outputVariable.isNotEmpty) {
        final variable = VariableFactory.fromObject(outputVariable, result);
        data.variables.set(variable);

        if (isCapture) {
          data.variables.markForCapture(outputVariable);
        }

        data.log('FUNCTION $functionName: Set $outputVariable = "$result"');
      }
    } catch (e, stackTrace) {
      data.logError('FUNCTION $functionName failed: $e');
      data.logError('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String> _executeFunction(
      String function, String input, BotData data) async {
    switch (function.toUpperCase()) {
      case 'CONSTANT':
        return input;

      case 'DELAY':
        final milliseconds = int.tryParse(input) ?? 0;
        await Future.delayed(Duration(milliseconds: milliseconds));
        data.log('Delayed for ${milliseconds}ms');
        return input;

      case 'TOLOWERCASE':
        return input.toLowerCase();

      case 'TOUPPERCASE':
        return input.toUpperCase();

      case 'LENGTH':
        return input.length.toString();

      case 'TRIM':
        return input.trim();

      case 'REVERSE':
      case 'REVERSESTRING':
        return input.split('').reversed.join('');

      case 'BASE64ENCODE':
        return base64Encode(utf8.encode(input));

      case 'BASE64DECODE':
        try {
          return utf8.decode(base64Decode(input));
        } catch (e) {
          data.logWarning('Base64 decode failed: $e');
          return input;
        }

      case 'URLENCODE':
        return Uri.encodeComponent(input);

      case 'URLDECODE':
        return Uri.decodeComponent(input);

      case 'UNESCAPE':
        try {
          // Unescape common escape sequences
          String result = input;
          result = result.replaceAll(r'\\', r'\');
          result = result.replaceAll(r'\n', '\n');
          result = result.replaceAll(r'\r', '\r');
          result = result.replaceAll(r'\t', '\t');
          result = result.replaceAll(r'\"', '"');
          result = result.replaceAll(r"\'", "'");
          return result;
        } catch (e) {
          data.logWarning('Unescape failed: $e');
          return input;
        }

      case 'HTMLENTITYENCODE':
        return input
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#39;');

      case 'HTMLENTITYDECODE':
        return input
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'");

      case 'RANDOMNUM':
        final min = int.tryParse(parameters['min']?.toString() ?? '0') ?? 0;
        final max = int.tryParse(parameters['max']?.toString() ?? '100') ?? 100;
        final randomZeroPad = parameters['randomZeroPad'] == true;
        final random = Random();
        final randomNum = min + random.nextInt(max - min);
        final result = randomNum.toString();

        if (randomZeroPad) {
          final maxLength = max.toString().length;
          return result.padLeft(maxLength, '0');
        }
        return result;

      case 'CURRENTUNIXTIME':
        return (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

      case 'UNIXTIMETOISO8601':
        try {
          final timestamp = double.parse(input);
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
              (timestamp * 1000).toInt(),
              isUtc: true);
          return dateTime.toIso8601String();
        } catch (e) {
          data.logWarning('Unix time to ISO8601 conversion failed: $e');
          return input;
        }

      case 'DATETOUNIXTIME':
        // Parse date with format if specified
        try {
          final format = parameters['format']?.toString();
          if (format != null) {
            final dateTime = DateTime.parse(input);
            return (dateTime.millisecondsSinceEpoch ~/ 1000).toString();
          } else {
            final dateTime = DateTime.parse(input);
            return (dateTime.millisecondsSinceEpoch ~/ 1000).toString();
          }
        } catch (e) {
          data.logWarning('Date parsing failed: $e');
          return input;
        }

      case 'UNIXTIMETODATE':
        try {
          final timestamp = int.parse(input);
          final dateTime =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          final format =
              parameters['format']?.toString() ?? 'yyyy-MM-dd HH:mm:ss';
          return _formatDateTime(dateTime, format);
        } catch (e) {
          data.logWarning('Unix time conversion failed: $e');
          return input;
        }

      case 'REPLACE':
        final what = parameters['what']?.toString() ?? '';
        final with_ = parameters['with']?.toString() ?? '';
        final useRegex = parameters['useRegex'] == true;

        if (useRegex) {
          try {
            return input.replaceAll(RegExp(what), with_);
          } catch (e) {
            data.logWarning('Regex replace failed: $e');
            return input.replaceAll(what, with_);
          }
        } else {
          return input.replaceAll(what, with_);
        }

      case 'REGEXMATCH':
        final pattern = parameters['pattern']?.toString() ?? '';
        try {
          final match = RegExp(pattern).firstMatch(input);
          return match?.group(0) ?? '';
        } catch (e) {
          data.logWarning('Regex match failed: $e');
          return '';
        }

      case 'SUBSTRING':
        final startIndex =
            int.tryParse(parameters['startIndex']?.toString() ?? '0') ?? 0;
        final length =
            int.tryParse(parameters['length']?.toString() ?? '1') ?? 1;

        if (startIndex >= input.length) return '';
        final endIndex = (startIndex + length).clamp(0, input.length);
        return input.substring(startIndex, endIndex);

      case 'CHARAT':
        final index = int.tryParse(parameters['index']?.toString() ?? '0') ?? 0;
        if (index >= 0 && index < input.length) {
          return input[index];
        }
        return '';

      case 'COUNTOCCURRENCES':
        final toFind = parameters['toFind']?.toString() ?? '';
        if (toFind.isEmpty) return '0';
        return (input.split(toFind).length - 1).toString();

      case 'TRANSLATE':
        String result = input;
        final dictionary =
            parameters['dictionary'] as Map<String, String>? ?? {};
        final stopAfterFirstMatch = parameters['stopAfterFirstMatch'] ?? true;
        int replacements = 0;

        final sortedEntries = dictionary.entries.toList()
          ..sort((a, b) => b.key.length.compareTo(a.key.length));

        for (final entry in sortedEntries) {
          if (result.contains(entry.key)) {
            if (stopAfterFirstMatch) {
              // Replace only the first occurrence
              final index = result.indexOf(entry.key);
              result = result.substring(0, index) +
                  entry.value +
                  result.substring(index + entry.key.length);
              replacements = 1;
              data.log(
                  'TRANSLATE: Replaced first occurrence of "${entry.key}" -> "${entry.value}"');
              break;
            } else {
              final occurrenceCount = result.split(entry.key).length - 1;
              replacements += occurrenceCount;
              result = result.replaceAll(entry.key, entry.value);
              data.log(
                  'TRANSLATE: Replaced all occurrences of "${entry.key}" -> "${entry.value}" ($occurrenceCount occurrence(s))');
            }
          }
        }

        data.log(
            'TRANSLATE: Total $replacements replacement(s) made. Result: "$result"');
        return result;

      case 'COMPUTE':
        try {
          // Replace comma with dot for decimal numbers
          final normalizedInput = input.replaceAll(',', '.');

          // Parse the expression
          final parser = Parser();
          final expression = parser.parse(normalizedInput);

          // Evaluate the expression
          final contextModel = ContextModel();
          final result = expression.evaluate(EvaluationType.REAL, contextModel);

          return result.toString();
        } catch (e) {
          // Fallback to basic evaluation
          try {
            return _evaluateBasicMath(input).toString();
          } catch (e2) {
            data.logWarning('Math computation failed: $e');
            return input;
          }
        }

      case 'RANDOMSTRING':
        String result = input;
        final random = Random();

        // Character sets
        const lowercase = 'abcdefghijklmnopqrstuvwxyz';
        const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        const digits = '0123456789';
        final symbols = r'\!"£$%&/()=?^' + "'" + r'{}[]@#,;.:-_*+';
        const hex = '0123456789abcdef';
        const upperDigits = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        const lowerDigits = 'abcdefghijklmnopqrstuvwxyz0123456789';
        const upperLower =
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        const lowerUpperDigits =
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        final allChars = lowercase + uppercase + digits + symbols;

        // Replace patterns with random characters
        result = result.replaceAllMapped(
            RegExp(r'\?l'), (_) => lowercase[random.nextInt(lowercase.length)]);
        result = result.replaceAllMapped(
            RegExp(r'\?u'), (_) => uppercase[random.nextInt(uppercase.length)]);
        result = result.replaceAllMapped(
            RegExp(r'\?d'), (_) => digits[random.nextInt(digits.length)]);
        result = result.replaceAllMapped(
            RegExp(r'\?s'), (_) => symbols[random.nextInt(symbols.length)]);
        result = result.replaceAllMapped(
            RegExp(r'\?h'), (_) => hex[random.nextInt(hex.length)]);
        result = result.replaceAllMapped(
            RegExp(r'\?a'), (_) => allChars[random.nextInt(allChars.length)]);
        result = result.replaceAllMapped(RegExp(r'\?m'),
            (_) => upperDigits[random.nextInt(upperDigits.length)]);
        result = result.replaceAllMapped(RegExp(r'\?n'),
            (_) => lowerDigits[random.nextInt(lowerDigits.length)]);
        result = result.replaceAllMapped(RegExp(r'\?i'),
            (_) => lowerUpperDigits[random.nextInt(lowerUpperDigits.length)]);
        result = result.replaceAllMapped(RegExp(r'\?f'),
            (_) => upperLower[random.nextInt(upperLower.length)]);

        data.log('RANDOMSTRING: Generated "$result" from pattern "$input"');
        return result;

      case 'GETRANDOMUA':
        // Return a random User-Agent
        final browser = parameters['browser']?.toString();
        final random = Random();

        if (browser != null) {
          // Browser-specific user agents
          switch (browser.toUpperCase()) {
            case 'CHROME':
              final chromeUAs = [
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              ];
              return chromeUAs[random.nextInt(chromeUAs.length)];

            case 'FIREFOX':
              final firefoxUAs = [
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15) Gecko/20100101 Firefox/89.0',
              ];
              return firefoxUAs[random.nextInt(firefoxUAs.length)];

            case 'OPERA':
              final operaUAs = [
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 OPR/77.0.4054.172',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 OPR/77.0.4054.172',
              ];
              return operaUAs[random.nextInt(operaUAs.length)];

            case 'SAFARI':
              final safariUAs = [
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15',
              ];
              return safariUAs[random.nextInt(safariUAs.length)];

            case 'EDGE':
              final edgeUAs = [
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59',
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36 Edg/92.0.902.55',
              ];
              return edgeUAs[random.nextInt(edgeUAs.length)];
          }
        }

        // Default: return random from all browsers
        final userAgents = [
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59',
        ];
        return userAgents[random.nextInt(userAgents.length)];

      case 'CLEARCOOKIES':
        data.cookies.clear();
        data.log('Cleared all cookies');
        return '';

      case 'GENERATEGUID':
        // Generate a GUID in the format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
        final random = Random();
        final hexChars = '0123456789abcdef';

        String generateHex(int length) {
          return List.generate(length, (_) => hexChars[random.nextInt(16)])
              .join();
        }

        // Generate the GUID parts
        final part1 = generateHex(8);
        final part2 = generateHex(4);
        final part3 = '4${generateHex(3)}'; // Version 4 UUID
        final yChar = hexChars[8 + random.nextInt(4)]; // y is 8, 9, a, or b
        final part4 = '$yChar${generateHex(3)}';
        final part5 = generateHex(12);

        return '$part1-$part2-$part3-$part4-$part5';

      case 'HASH':
        final algorithm = parameters['hashType']?.toString() ?? 'SHA256';
        final inputBase64 = parameters['inputBase64'] == true;
        try {
          String dataToHash = input;
          if (inputBase64) {
            // If input is base64, decode it first
            try {
              final decoded = base64Decode(input);
              dataToHash = utf8.decode(decoded);
            } catch (e) {
              data.logWarning('Base64 decode for hash input failed: $e');
            }
          }
          return CryptoHelper.computeHash(dataToHash, algorithm);
        } catch (e) {
          data.logWarning('Hash computation failed: $e');
          return input;
        }

      case 'HMAC':
        final key = parameters['key']?.toString() ?? '';
        final algorithm = parameters['algorithm']?.toString() ?? 'SHA256';
        final hmacBase64 = parameters['hmacBase64'] == true;
        final keyBase64 = parameters['keyBase64'] == true;

        try {
          return CryptoHelper.computeHmac(
              input, key, algorithm, hmacBase64, keyBase64);
        } catch (e) {
          data.logWarning('HMAC computation failed: $e');
          return input;
        }

      case 'AESENCRYPT':
        final secretKey = parameters['secretKey']?.toString() ?? '';
        final iv = parameters['iv']?.toString() ?? '';
        final mode = parameters['mode']?.toString() ?? 'CBC';
        final padding = parameters['padding']?.toString() ?? 'PKCS7';

        try {
          if (iv.isEmpty) {
            return CryptoHelper.aesEncrypt(input, secretKey);
          } else {
            return CryptoHelper.aesEncryptWithIV(input, secretKey, iv,
                mode: mode, padding: padding);
          }
        } catch (e) {
          data.logWarning('AES encryption failed: $e');
          return input;
        }

      case 'AESDECRYPT':
        final secretKey = parameters['secretKey']?.toString() ?? '';
        final iv = parameters['iv']?.toString() ?? '';
        final mode = parameters['mode']?.toString() ?? 'CBC';
        final padding = parameters['padding']?.toString() ?? 'PKCS7';

        try {
          if (iv.isEmpty) {
            return CryptoHelper.aesDecrypt(input, secretKey);
          } else {
            return CryptoHelper.aesDecryptWithIV(input, secretKey, iv,
                mode: mode, padding: padding);
          }
        } catch (e) {
          data.logWarning('AES decryption failed: $e');
          return input;
        }

      case 'RSAENCRYPT':
        final modulus = parameters['modulus']?.toString() ?? '';
        final exponent = parameters['exponent']?.toString() ?? '';
        final oaep = parameters['oaep'] ?? true;
        try {
          return CryptoHelper.rsaEncrypt(input, modulus, exponent, oaep);
        } catch (e) {
          data.logWarning('RSA encryption failed: $e');
          return input;
        }

      case 'RSAPKCS1PAD2':
        final modulus = parameters['modulus']?.toString() ?? '';
        final exponent = parameters['exponent']?.toString() ?? '';
        try {
          return CryptoHelper.rsaPKCS1PAD2(input, modulus, exponent);
        } catch (e) {
          data.logWarning('RSA PKCS1PAD2 encryption failed: $e');
          return input;
        }

      case 'PBKDF2PKCS5':
        final salt = parameters['salt']?.toString() ?? '';
        final saltSize =
            int.tryParse(parameters['saltSize']?.toString() ?? '8') ?? 8;
        final iterations =
            int.tryParse(parameters['iterations']?.toString() ?? '1') ?? 1;
        final keySize =
            int.tryParse(parameters['keySize']?.toString() ?? '16') ?? 16;
        final algorithm = parameters['algorithm']?.toString() ?? 'SHA1';
        try {
          return CryptoHelper.pbkdf2PKCS5(
              input, salt, saltSize, iterations, keySize, algorithm);
        } catch (e) {
          data.logWarning('PBKDF2 key derivation failed: $e');
          return input;
        }

      default:
        data.logWarning('Unsupported function: $function');
        return input;
    }
  }

  String _formatDateTime(DateTime dateTime, String format) {
    String result = format;
    result =
        result.replaceAll('yyyy', dateTime.year.toString().padLeft(4, '0'));
    result = result.replaceAll('MM', dateTime.month.toString().padLeft(2, '0'));
    result = result.replaceAll('dd', dateTime.day.toString().padLeft(2, '0'));
    result = result.replaceAll('HH', dateTime.hour.toString().padLeft(2, '0'));
    result =
        result.replaceAll('mm', dateTime.minute.toString().padLeft(2, '0'));
    result =
        result.replaceAll('ss', dateTime.second.toString().padLeft(2, '0'));
    return result;
  }

  double _evaluateBasicMath(String expression) {
    expression = expression.replaceAll(' ', '');

    if (expression.contains('+')) {
      final parts = expression.split('+');
      return parts.map((p) => double.parse(p)).reduce((a, b) => a + b);
    } else if (expression.contains('-')) {
      final parts = expression.split('-');
      if (parts.length == 2) {
        return double.parse(parts[0]) - double.parse(parts[1]);
      }
    } else if (expression.contains('*')) {
      final parts = expression.split('*');
      return parts.map((p) => double.parse(p)).reduce((a, b) => a * b);
    } else if (expression.contains('/')) {
      final parts = expression.split('/');
      if (parts.length == 2) {
        return double.parse(parts[0]) / double.parse(parts[1]);
      }
    }

    return double.parse(expression);
  }

  @override
  void fromLoliCode(String content) {
    // Parse FUNCTION statement using the statement parser
    // Format: FUNCTION Name [ARGUMENTS] ["INPUT STRING"] [-> VAR/CAP "NAME"]

    var trimmed = content.trim();

    // Parse label if present (#LABEL prefix)
    final labelMatch = RegExp(r'^#([A-Za-z0-9_]+)\s+(.*)$').firstMatch(trimmed);
    if (labelMatch != null) {
      _labelText = labelMatch.group(1)!;
      trimmed = labelMatch.group(2)!.trim();
    }

    // Extract function name after "FUNCTION" keyword
    final functionMatch =
        RegExp(r'^FUNCTION\s+([A-Za-z0-9]+)', caseSensitive: false)
            .firstMatch(trimmed);
    if (functionMatch == null) {
      return;
    }

    functionName = functionMatch.group(1) ?? '';
    var remaining = trimmed.substring(functionMatch.end).trim();

    // Parse based on function type
    switch (functionName.toUpperCase()) {
      case 'CONSTANT':
        // FUNCTION Constant "value" -> CAP "varName"
        final quotedMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
        if (quotedMatch != null) {
          inputString = quotedMatch.group(1) ?? '';
          remaining = remaining.substring(quotedMatch.end).trim();
        }
        break;

      case 'GENERATEGUID':
        // FUNCTION GenerateGUID -> VAR "varName"
        inputString = '';
        break;

      case 'DELAY':
        // FUNCTION Delay "10000" or FUNCTION Delay 10000
        final quotedMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
        if (quotedMatch != null) {
          inputString = quotedMatch.group(1) ?? '';
          remaining = remaining.substring(quotedMatch.end).trim();
        } else {
          // Try unquoted numeric
          try {
            final numValue = LineParser.parseNumeric(remaining);
            inputString = numValue.toString();
            remaining = LineParser.consumeNumeric(remaining);
          } catch (e) {
            // Fallback to empty
            inputString = '';
          }
        }
        break;

      case 'RANDOMNUM':
        // FUNCTION RandomNum "0" "100" [RandomZeroPad=True/False] -> VAR "output"
        try {
          var minMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (minMatch != null) {
            parameters['min'] = minMatch.group(1) ?? '0';
            remaining = remaining.substring(minMatch.end).trim();

            // Parse second quoted string for max
            var maxMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
            if (maxMatch != null) {
              parameters['max'] = maxMatch.group(1) ?? '100';
              remaining = remaining.substring(maxMatch.end).trim();
            }
          } else {
            // Fallback to numeric parsing
            final min = LineParser.parseNumeric(remaining);
            remaining = LineParser.consumeNumeric(remaining);
            final max = LineParser.parseNumeric(remaining);
            remaining = LineParser.consumeNumeric(remaining);

            parameters['min'] = min.toString();
            parameters['max'] = max.toString();
          }

          // Check for optional RandomZeroPad boolean
          final zeroPadMatch =
              RegExp(r'^RandomZeroPad=(True|False)', caseSensitive: false)
                  .firstMatch(remaining);
          if (zeroPadMatch != null) {
            parameters['randomZeroPad'] =
                zeroPadMatch.group(1)?.toLowerCase() == 'true';
            remaining = remaining.substring(zeroPadMatch.end).trim();
          }
        } catch (e) {
          // Use defaults
          parameters['min'] = '0';
          parameters['max'] = '100';
        }
        break;

      case 'REPLACE':
        // FUNCTION Replace "what" "with" [UseRegex=True/False] "input" -> VAR "output"
        var whatMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
        if (whatMatch != null) {
          parameters['what'] = whatMatch.group(1) ?? '';
          remaining = remaining.substring(whatMatch.end).trim();
        }

        var withMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
        if (withMatch != null) {
          parameters['with'] = withMatch.group(1) ?? '';
          remaining = remaining.substring(withMatch.end).trim();
        }

        // Check for optional UseRegex boolean
        final booleanMatch =
            RegExp(r'^UseRegex=(True|False)', caseSensitive: false)
                .firstMatch(remaining);
        if (booleanMatch != null) {
          parameters['useRegex'] =
              booleanMatch.group(1)?.toLowerCase() == 'true';
          remaining = remaining.substring(booleanMatch.end).trim();
        }

        // Parse input string
        final inputMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
        if (inputMatch != null) {
          inputString = inputMatch.group(1) ?? '';
          remaining = remaining.substring(inputMatch.end).trim();
        }
        break;

      case 'TRANSLATE':
        // FUNCTION Translate [StopAfterFirstMatch=True/False] KEY "key1" VALUE "value1" KEY "key2" VALUE "value2" "input" -> CAP "output"
        final dictionary = <String, String>{};

        parameters['stopAfterFirstMatch'] = true;

        final boolMatch = RegExp(r'^(StopAfterFirstMatch=)?(True|False)\s+',
                caseSensitive: false)
            .firstMatch(remaining);
        if (boolMatch != null) {
          parameters['stopAfterFirstMatch'] =
              boolMatch.group(2)?.toLowerCase() == 'true';
          remaining = remaining.substring(boolMatch.end).trim();
        }

        // Parse KEY "key" VALUE "value" pairs
        while (remaining.toUpperCase().startsWith('KEY ')) {
          remaining = remaining.substring(4).trim(); // Skip 'KEY '

          // Parse key
          final keyMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (keyMatch == null) break;
          final key = keyMatch.group(1) ?? '';
          remaining = remaining.substring(keyMatch.end).trim();

          // Check for VALUE
          if (!remaining.toUpperCase().startsWith('VALUE ')) break;
          remaining = remaining.substring(6).trim();

          // Parse value
          final valueMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (valueMatch == null) break;
          final value = valueMatch.group(1) ?? '';
          remaining = remaining.substring(valueMatch.end).trim();

          dictionary[key] = value;
        }

        parameters['dictionary'] = dictionary;

        // Parse input string
        final inputMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
        if (inputMatch != null) {
          inputString = inputMatch.group(1) ?? '';
          remaining = remaining.substring(inputMatch.end).trim();
        }
        break;

      default:
        // Generic parsing for other functions

        // Check for hash functions with hash type parameter
        if (functionName.toUpperCase() == 'HASH') {
          // FUNCTION Hash SHA256 [InputBase64=True/False] "input" -> VAR "output"
          final hashTypeMatch =
              RegExp(r'^(SHA1|SHA256|SHA384|SHA512|MD5)', caseSensitive: false)
                  .firstMatch(remaining);
          if (hashTypeMatch != null) {
            parameters['hashType'] = hashTypeMatch.group(1)!.toUpperCase();
            remaining = remaining.substring(hashTypeMatch.end).trim();
          }

          // Check for optional InputBase64 parameter
          final inputBase64Match =
              RegExp(r'^InputBase64=(True|False)', caseSensitive: false)
                  .firstMatch(remaining);
          if (inputBase64Match != null) {
            parameters['inputBase64'] =
                inputBase64Match.group(1)?.toLowerCase() == 'true';
            remaining = remaining.substring(inputBase64Match.end).trim();
          }
        }

        // Check for HMAC functions
        if (functionName.toUpperCase() == 'HMAC') {
          // FUNCTION HMAC SHA1 "key" HmacBase64=True KeyBase64=False "input" -> VAR "output"
          final hmacAlgoMatch =
              RegExp(r'^(SHA1|SHA256|SHA384|SHA512|MD5)', caseSensitive: false)
                  .firstMatch(remaining);
          if (hmacAlgoMatch != null) {
            parameters['algorithm'] = hmacAlgoMatch.group(1)!.toUpperCase();
            remaining = remaining.substring(hmacAlgoMatch.end).trim();
          }

          // Parse key
          final keyMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (keyMatch != null) {
            parameters['key'] = keyMatch.group(1) ?? '';
            remaining = remaining.substring(keyMatch.end).trim();
          }

          // Parse optional boolean parameters
          final hmacBase64Match =
              RegExp(r'^HmacBase64=(True|False)', caseSensitive: false)
                  .firstMatch(remaining);
          if (hmacBase64Match != null) {
            parameters['hmacBase64'] =
                hmacBase64Match.group(1)?.toLowerCase() == 'true';
            remaining = remaining.substring(hmacBase64Match.end).trim();
          }

          final keyBase64Match =
              RegExp(r'^KeyBase64=(True|False)', caseSensitive: false)
                  .firstMatch(remaining);
          if (keyBase64Match != null) {
            parameters['keyBase64'] =
                keyBase64Match.group(1)?.toLowerCase() == 'true';
            remaining = remaining.substring(keyBase64Match.end).trim();
          }
        }

        // Check for AES functions
        if (functionName.toUpperCase() == 'AESENCRYPT' ||
            functionName.toUpperCase() == 'AESDECRYPT') {
          // FUNCTION AesEncrypt "key" "iv" Mode Padding "input" -> VAR "encrypted"
          final keyMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (keyMatch != null) {
            parameters['secretKey'] = keyMatch.group(1) ?? '';
            remaining = remaining.substring(keyMatch.end).trim();

            final ivMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
            if (ivMatch != null) {
              parameters['iv'] = ivMatch.group(1) ?? '';
              remaining = remaining.substring(ivMatch.end).trim();

              // Check for optional Mode
              final modeMatch =
                  RegExp(r'^(CBC|ECB|CFB|OFB|CTR)', caseSensitive: false)
                      .firstMatch(remaining);
              if (modeMatch != null) {
                parameters['mode'] = modeMatch.group(1)!.toUpperCase();
                remaining = remaining.substring(modeMatch.end).trim();
              }

              // Check for optional Padding
              final paddingMatch = RegExp(
                      r'^(None|PKCS7|Zeros|ANSIX923|ISO10126)',
                      caseSensitive: false)
                  .firstMatch(remaining);
              if (paddingMatch != null) {
                parameters['padding'] = paddingMatch.group(1)!;
                remaining = remaining.substring(paddingMatch.end).trim();
              }
            }
          }
        }

        // Check for date functions with format parameter
        if (functionName.toUpperCase() == 'DATETOUNIXTIME') {
          // FUNCTION DateToUnixTime "format" "input" -> VAR "output"
          final formatMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (formatMatch != null) {
            parameters['format'] = formatMatch.group(1) ?? '';
            remaining = remaining.substring(formatMatch.end).trim();
          }
        }

        if (functionName.toUpperCase() == 'UNIXTIMETODATE') {
          // FUNCTION UnixTimeToDate "format" "input" -> VAR "output"
          final formatMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (formatMatch != null) {
            final possibleFormat = formatMatch.group(1) ?? '';
            remaining = remaining.substring(formatMatch.end).trim();

            final inputMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
            if (inputMatch != null) {
              parameters['format'] = possibleFormat;
              inputString = inputMatch.group(1) ?? '';
              remaining = remaining.substring(inputMatch.end).trim();
            } else {
              inputString = possibleFormat;
              parameters['format'] = 'yyyy-MM-dd:HH-mm-ss';
            }
            // Input already parsed, skip to next section
            break;
          }
        }

        // Check for SUBSTRING function parameters
        if (functionName.toUpperCase() == 'SUBSTRING') {
          // FUNCTION Substring "startindex" "length" "input" -> VAR "output"
          final startMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (startMatch != null) {
            parameters['startIndex'] = startMatch.group(1) ?? '0';
            remaining = remaining.substring(startMatch.end).trim();

            final lengthMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
            if (lengthMatch != null) {
              parameters['length'] = lengthMatch.group(1) ?? '1';
              remaining = remaining.substring(lengthMatch.end).trim();
            }
          }
        }

        // Check for CHARAT function parameters
        if (functionName.toUpperCase() == 'CHARAT') {
          // FUNCTION CharAt "index" "input" -> VAR "output"
          final indexMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (indexMatch != null) {
            parameters['index'] = indexMatch.group(1) ?? '0';
            remaining = remaining.substring(indexMatch.end).trim();
          }
        }

        // Check for COUNTOCCURRENCES function parameters
        if (functionName.toUpperCase() == 'COUNTOCCURRENCES') {
          // FUNCTION CountOccurrences "tofind" "input" -> VAR "output"
          final toFindMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (toFindMatch != null) {
            parameters['toFind'] = toFindMatch.group(1) ?? '';
            remaining = remaining.substring(toFindMatch.end).trim();
          }
        }

        // Check for RANDOMSTRING function
        if (functionName.toUpperCase() == 'RANDOMSTRING') {
          // FUNCTION RandomString "?l?l?l?d?d?d" -> VAR "output"
          // The pattern is in the input string
        }

        // Check for GetRandomUA function
        if (functionName.toUpperCase() == 'GETRANDOMUA') {
          // FUNCTION GetRandomUA [BROWSER Chrome/Firefox/Opera/Safari/Edge] -> VAR "output"
          if (remaining.toUpperCase().startsWith('BROWSER ')) {
            remaining = remaining.substring(8).trim();

            final browserMatch = RegExp(r'^(Chrome|Firefox|Opera|Safari|Edge)',
                    caseSensitive: false)
                .firstMatch(remaining);
            if (browserMatch != null) {
              parameters['browser'] = browserMatch.group(1)!;
              remaining = remaining.substring(browserMatch.end).trim();
            }
          }
        }

        // Check for RSA functions
        if (functionName.toUpperCase() == 'RSAENCRYPT') {
          // FUNCTION RSAEncrypt "modulus" "exponent" [RsaOAEP=True/False] "input" -> VAR "output"
          final modulusMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (modulusMatch != null) {
            parameters['modulus'] = modulusMatch.group(1) ?? '';
            remaining = remaining.substring(modulusMatch.end).trim();

            final exponentMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
            if (exponentMatch != null) {
              parameters['exponent'] = exponentMatch.group(1) ?? '';
              remaining = remaining.substring(exponentMatch.end).trim();
            }
          }

          // Check for optional OAEP parameter
          final oaepMatch =
              RegExp(r'^RsaOAEP=(True|False)', caseSensitive: false)
                  .firstMatch(remaining);
          if (oaepMatch != null) {
            parameters['oaep'] = oaepMatch.group(1)?.toLowerCase() == 'true';
            remaining = remaining.substring(oaepMatch.end).trim();
          } else {
            parameters['oaep'] = true;
          }
        }

        if (functionName.toUpperCase() == 'RSAPKCS1PAD2') {
          // FUNCTION RSAPKCS1PAD2 "modulus" "exponent" "input" -> VAR "output"
          final modulusMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (modulusMatch != null) {
            parameters['modulus'] = modulusMatch.group(1) ?? '';
            remaining = remaining.substring(modulusMatch.end).trim();

            final exponentMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
            if (exponentMatch != null) {
              parameters['exponent'] = exponentMatch.group(1) ?? '';
              remaining = remaining.substring(exponentMatch.end).trim();
            }
          }
        }

        if (functionName.toUpperCase() == 'PBKDF2PKCS5') {
          // FUNCTION PBKDF2PKCS5 ["salt" or saltSize] iterations keySize algorithm "input" -> VAR "output"
          final saltMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
          if (saltMatch != null) {
            parameters['salt'] = saltMatch.group(1) ?? '';
            remaining = remaining.substring(saltMatch.end).trim();
          } else {
            // Try to parse salt size as numeric
            try {
              final saltSize = LineParser.parseNumeric(remaining);
              parameters['saltSize'] = saltSize.toString();
              remaining = LineParser.consumeNumeric(remaining);
            } catch (e) {
              parameters['saltSize'] = '8';
            }
          }

          // Parse iterations
          try {
            final iterations = LineParser.parseNumeric(remaining);
            parameters['iterations'] = iterations.toString();
            remaining = LineParser.consumeNumeric(remaining);
          } catch (e) {
            parameters['iterations'] = '1';
          }

          // Parse key size
          try {
            final keySize = LineParser.parseNumeric(remaining);
            parameters['keySize'] = keySize.toString();
            remaining = LineParser.consumeNumeric(remaining);
          } catch (e) {
            parameters['keySize'] = '16';
          }

          // Parse algorithm
          final algoMatch =
              RegExp(r'^(SHA1|SHA256|SHA384|SHA512|MD5)', caseSensitive: false)
                  .firstMatch(remaining);
          if (algoMatch != null) {
            parameters['algorithm'] = algoMatch.group(1)!.toUpperCase();
            remaining = remaining.substring(algoMatch.end).trim();
          } else {
            parameters['algorithm'] = 'SHA1';
          }
        }

        // Parse quoted input string
        final quotedMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
        if (quotedMatch != null) {
          inputString = quotedMatch.group(1) ?? '';
          remaining = remaining.substring(quotedMatch.end).trim();
        }
        break;
    }

    // Parse output variable (->VAR or ->CAP)
    final outputMatch =
        RegExp(r'->\s*(VAR|CAP)\s+"([^"]*)"').firstMatch(remaining);
    if (outputMatch != null) {
      isCapture = outputMatch.group(1) == 'CAP';
      outputVariable = outputMatch.group(2) ?? '';
    }
  }

  @override
  String toLoliCode() {
    String result = 'FUNCTION $functionName';

    // Add function-specific parameters
    switch (functionName.toUpperCase()) {
      case 'RANDOMNUM':
        final min = parameters['min'] ?? '0';
        final max = parameters['max'] ?? '100';
        result += ' "$min" "$max"';
        if (parameters['randomZeroPad'] == true) {
          result += ' RandomZeroPad=True';
        }
        break;

      case 'REPLACE':
        final what = parameters['what'] ?? '';
        final with_ = parameters['with'] ?? '';
        result += ' "$what" "$with_"';
        if (parameters['useRegex'] == true) {
          result += ' UseRegex=True';
        }
        break;

      case 'HASH':
        final hashType = parameters['hashType'] ?? 'SHA256';
        result += ' $hashType';
        if (parameters['inputBase64'] == true) {
          result += ' InputBase64=True';
        }
        break;

      case 'HMAC':
        final algorithm = parameters['algorithm'] ?? 'SHA256';
        final key = parameters['key'] ?? '';
        result += ' $algorithm "$key"';
        if (parameters['hmacBase64'] == true) {
          result += ' HmacBase64=True';
        }
        if (parameters['keyBase64'] == true) {
          result += ' KeyBase64=True';
        }
        break;

      case 'AESENCRYPT':
      case 'AESDECRYPT':
        final secretKey = parameters['secretKey'] ?? '';
        result += ' "$secretKey"';
        final iv = parameters['iv']?.toString() ?? '';
        if (iv.isNotEmpty) {
          result += ' "$iv"';
          final mode = parameters['mode']?.toString();
          if (mode != null && mode != 'CBC') {
            result += ' $mode';
          }
          final padding = parameters['padding']?.toString();
          if (padding != null && padding != 'PKCS7') {
            result += ' $padding';
          }
        }
        break;

      case 'DATETOUNIXTIME':
      case 'UNIXTIMETODATE':
        final format = parameters['format'] ?? '';
        if (format.isNotEmpty) {
          result += ' "$format"';
        }
        break;

      case 'SUBSTRING':
        final startIndex = parameters['startIndex'] ?? '0';
        final length = parameters['length'] ?? '1';
        result += ' "$startIndex" "$length"';
        break;

      case 'CHARAT':
        final index = parameters['index'] ?? '0';
        result += ' "$index"';
        break;

      case 'COUNTOCCURRENCES':
        final toFind = parameters['toFind'] ?? '';
        result += ' "$toFind"';
        break;

      case 'TRANSLATE':
        if (parameters['stopAfterFirstMatch'] == false) {
          result += ' StopAfterFirstMatch=False';
        }
        final dictionary =
            parameters['dictionary'] as Map<String, String>? ?? {};
        for (final entry in dictionary.entries) {
          result += ' KEY "${entry.key}" VALUE "${entry.value}"';
        }
        break;

      case 'GETRANDOMUA':
        final browser = parameters['browser']?.toString();
        if (browser != null) {
          result += ' BROWSER $browser';
        }
        break;

      case 'RSAENCRYPT':
        final modulus = parameters['modulus'] ?? '';
        final exponent = parameters['exponent'] ?? '';
        result += ' "$modulus" "$exponent"';
        if (parameters['oaep'] == false) {
          result += ' RsaOAEP=False';
        }
        break;

      case 'RSAPKCS1PAD2':
        final modulus = parameters['modulus'] ?? '';
        final exponent = parameters['exponent'] ?? '';
        result += ' "$modulus" "$exponent"';
        break;

      case 'PBKDF2PKCS5':
        if (parameters['salt'] != null &&
            parameters['salt'].toString().isNotEmpty) {
          result += ' "${parameters['salt']}"';
        } else {
          final saltSize = parameters['saltSize'] ?? '8';
          result += ' $saltSize';
        }
        final iterations = parameters['iterations'] ?? '1';
        final keySize = parameters['keySize'] ?? '16';
        final algorithm = parameters['algorithm'] ?? 'SHA1';
        result += ' $iterations $keySize $algorithm';
        break;
    }

    // Add input string if present
    if (inputString.isNotEmpty) {
      result += ' "$inputString"';
    }

    // Add output variable if present
    if (outputVariable.isNotEmpty) {
      result += ' -> ${isCapture ? 'CAP' : 'VAR'} "$outputVariable"';
    }

    return result;
  }
}
