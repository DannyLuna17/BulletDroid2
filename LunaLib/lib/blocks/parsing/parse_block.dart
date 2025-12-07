import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import '../base/block_instance.dart';
import '../../core/bot_data.dart';
import '../../parsing/line_parser.dart';
import '../../parsing/interpolation_engine.dart';
import '../../variables/variable_factory.dart';

enum ParseMode { LR, Regex, JSON, CSS }

class ParseBlock extends BlockInstance {
  String input = '';
  ParseMode mode = ParseMode.LR;

  String leftDelim = '';
  String rightDelim = '';
  bool useRegexLR = false;

  String regex = '';
  bool dotMatches = false;
  bool caseSensitive = true;

  String jsonPath = '';
  bool jTokenParsing = false;

  String cssSelector = '';
  String cssAttribute = '';
  int cssIndex = -1;

  bool recursive = false;
  bool encodeOutput = false;
  bool createEmpty = false;

  String outputType = 'VAR';
  String outputVariable = 'PARSED';
  String prefix = '';
  String suffix = '';

  ParseBlock() : super(id: 'Parse');

  @override
  Future<void> execute(BotData data) async {
    try {
      final interpolatedInput =
          InterpolationEngine.interpolate(input, data.variables, data);
      final source =
          interpolatedInput.isEmpty ? data.responseSource : interpolatedInput;

      List<String> results = [];

      switch (mode) {
        case ParseMode.LR:
          results = _parseLR(source, data);
          break;
        case ParseMode.Regex:
          results = _parseRegex(source, data);
          break;
        case ParseMode.JSON:
          results = _parseJSON(source, data);
          break;
        case ParseMode.CSS:
          results = _parseCSS(source, data);
          break;
      }

      if (results.isEmpty && createEmpty) {
        results = [''];
      }

      if (prefix.isNotEmpty || suffix.isNotEmpty) {
        results = results.map((result) => '$prefix$result$suffix').toList();
      }

      if (encodeOutput) {
        results = results.map((result) => Uri.encodeComponent(result)).toList();
      }

      // Store results
      if (results.isEmpty) {
        final variable = VariableFactory.fromObject(outputVariable, '');
        data.variables.set(variable);

        if (outputType == 'CAP') {
          data.variables.markForCapture(outputVariable);
        }
      } else if (results.length == 1) {
        final variable =
            VariableFactory.fromObject(outputVariable, results.first);
        data.variables.set(variable);

        if (outputType == 'CAP') {
          data.variables.markForCapture(outputVariable);
        }
      } else {
        final variable = VariableFactory.fromObject(outputVariable, results);
        data.variables.set(variable);

        if (outputType == 'CAP') {
          data.variables.markForCapture(outputVariable);
        }
      }
    } catch (e) {
      data.log('Parse failed: $e');

      if (createEmpty) {
        final variable = VariableFactory.fromObject(outputVariable, '');
        data.variables.set(variable);
        if (outputType == 'CAP') {
          data.variables.markForCapture(outputVariable);
        }
      }

      if (!createEmpty) {
        throw e;
      }
    }
  }

  List<String> _parseLR(String source, BotData data) {
    final results = <String>[];
    final leftInterpolated =
        InterpolationEngine.interpolate(leftDelim, data.variables, data);
    final rightInterpolated =
        InterpolationEngine.interpolate(rightDelim, data.variables, data);

    var searchStart = 0;

    do {
      int leftIndex, rightIndex;

      if (useRegexLR) {
        // Use regex for LR parsing
        final leftPattern = RegExp(leftInterpolated,
            caseSensitive: caseSensitive, dotAll: dotMatches);
        final leftMatch = leftPattern.firstMatch(source.substring(searchStart));
        if (leftMatch == null) break;

        leftIndex = searchStart + leftMatch.start;
        final afterLeft = searchStart + leftMatch.end;

        final rightPattern = RegExp(rightInterpolated,
            caseSensitive: caseSensitive, dotAll: dotMatches);
        final rightMatch = rightPattern.firstMatch(source.substring(afterLeft));
        if (rightMatch == null) break;

        rightIndex = afterLeft + rightMatch.start;
        searchStart = afterLeft + rightMatch.end;

        final extracted = source.substring(afterLeft, rightIndex);
        results.add(extracted);
      } else {
        // Use string matching for LR parsing
        leftIndex = source.indexOf(leftInterpolated, searchStart);
        if (leftIndex == -1) {
          break;
        }

        rightIndex = source.indexOf(
            rightInterpolated, leftIndex + leftInterpolated.length);
        if (rightIndex == -1) {
          break;
        }

        final extracted =
            source.substring(leftIndex + leftInterpolated.length, rightIndex);
        results.add(extracted);

        searchStart = rightIndex + rightInterpolated.length;
      }
    } while (recursive);

    return results;
  }

  List<String> _parseRegex(String source, BotData data) {
    final interpolatedRegex =
        InterpolationEngine.interpolate(regex, data.variables, data);
    final pattern = RegExp(interpolatedRegex,
        caseSensitive: caseSensitive, dotAll: dotMatches);
    final matches = pattern.allMatches(source);

    final results = <String>[];
    for (final match in matches) {
      if (match.groupCount > 0) {
        results.add(match.group(1) ?? '');
      } else {
        results.add(match.group(0) ?? '');
      }

      if (!recursive) break;
    }

    return results;
  }

  List<String> _parseJSON(String source, BotData data) {
    try {
      final json = jsonDecode(source);
      final interpolatedPath =
          InterpolationEngine.interpolate(jsonPath, data.variables, data);

      if (jTokenParsing) {
        return _parseJSONAdvanced(json, interpolatedPath);
      } else {
        return _parseJSONSimple(json, interpolatedPath);
      }
    } catch (e) {
      return [];
    }
  }

  List<String> _parseJSONSimple(dynamic json, String path) {
    final pathParts = path.split('.');
    dynamic current = json;

    for (final part in pathParts) {
      if (current == null) return [];

      // Handle array indices like [0] or field[0]
      if (part.contains('[') && part.contains(']')) {
        final fieldName = part.substring(0, part.indexOf('['));
        final indexStr =
            part.substring(part.indexOf('[') + 1, part.indexOf(']'));

        if (fieldName.isNotEmpty && current is Map) {
          current = current[fieldName];
        }

        if (current is List) {
          if (indexStr == '*') {
            return current.map((e) => e.toString()).toList();
          } else {
            final index = int.tryParse(indexStr);
            if (index != null && index < current.length) {
              current = current[index];
            } else {
              return [];
            }
          }
        } else {
          return [];
        }
      } else {
        if (current is Map) {
          current = current[part];
        } else {
          return [];
        }
      }
    }

    // Convert result to string
    if (current != null) {
      if (current is List) {
        return current.map((e) => e.toString()).toList();
      } else {
        return [current.toString()];
      }
    }

    return [];
  }

  List<String> _parseJSONAdvanced(dynamic json, String path) {
    return _parseJSONSimple(json, path);
  }

  List<String> _parseCSS(String source, BotData data) {
    try {
      final interpolatedSelector =
          InterpolationEngine.interpolate(cssSelector, data.variables, data);
      final interpolatedAttribute =
          InterpolationEngine.interpolate(cssAttribute, data.variables, data);

      final document = html_parser.parse(source);
      final elements = document.querySelectorAll(interpolatedSelector);

      if (elements.isEmpty) return [];

      final results = <String>[];
      final elementsToProcess = cssIndex >= 0 && cssIndex < elements.length
          ? [elements[cssIndex]]
          : elements;

      for (final element in elementsToProcess) {
        String result;

        if (interpolatedAttribute.isEmpty ||
            interpolatedAttribute.toLowerCase() == 'innertext') {
          result = element.text;
        } else if (interpolatedAttribute.toLowerCase() == 'innerhtml') {
          result = element.innerHtml;
        } else if (interpolatedAttribute.toLowerCase() == 'outerhtml') {
          result = element.outerHtml;
        } else {
          result = element.attributes[interpolatedAttribute] ?? '';
        }

        results.add(result);

        if (!recursive) break;
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  @override
  void fromLoliCode(String content) {
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Handle syntax: PARSE "input" MODE "params" [options] -> VAR/CAP "variable" ["prefix" "suffix"]
      if (trimmed.startsWith('PARSE ')) {
        _parseOpenBulletSyntax(trimmed);
      } else if (trimmed.startsWith('input = ')) {
        input = LineParser.parseLiteral(trimmed.substring(8));
      } else if (trimmed.startsWith('mode = ')) {
        final modeStr = LineParser.parseToken(trimmed.substring(7));
        mode = ParseMode.values.firstWhere(
          (m) => m.toString().split('.').last == modeStr,
          orElse: () => ParseMode.LR,
        );
      } else if (trimmed.startsWith('leftDelim = ')) {
        leftDelim = LineParser.parseLiteral(trimmed.substring(12));
      } else if (trimmed.startsWith('rightDelim = ')) {
        rightDelim = LineParser.parseLiteral(trimmed.substring(13));
      } else if (trimmed.startsWith('regex = ')) {
        regex = LineParser.parseLiteral(trimmed.substring(8));
      } else if (trimmed.startsWith('jsonPath = ')) {
        jsonPath = LineParser.parseLiteral(trimmed.substring(11));
      } else if (trimmed.startsWith('cssSelector = ')) {
        cssSelector = LineParser.parseLiteral(trimmed.substring(14));
      } else if (trimmed.startsWith('cssAttribute = ')) {
        cssAttribute = LineParser.parseLiteral(trimmed.substring(15));
      } else if (trimmed.startsWith('recursive = ')) {
        recursive = LineParser.parseBool(trimmed.substring(12));
      } else if (trimmed.startsWith('=> VAR ')) {
        outputType = 'VAR';
        outputVariable = LineParser.parseToken(trimmed.substring(7));
      } else if (trimmed.startsWith('=> CAP ')) {
        outputType = 'CAP';
        outputVariable = LineParser.parseToken(trimmed.substring(7));
      }
    }
  }

  void _parseOpenBulletSyntax(String line) {
    // Parse: PARSE "input" LR "left" "right" Recursive=True -> CAP "variable" "$" ""
    // Parse: PARSE "input" JSON "jsonPath" JTokenParsing=True -> VAR "variable"
    // Parse: PARSE "input" REGEX "pattern" CaseSensitive=False -> VAR "variable"
    // Parse: PARSE "input" CSS "selector" "attribute" INDEX=0 -> VAR "variable"

    var remaining = line.substring(5).trim(); // Remove "PARSE"

    // Extract input using LineParser
    try {
      input = LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);
    } catch (e) {
      final inputMatch = RegExp(r'^(\S+)').firstMatch(remaining);
      if (inputMatch != null) {
        input = inputMatch.group(1)!;
        remaining = remaining.substring(inputMatch.end).trim();
      }
    }

    // Extract mode
    final modeMatch = RegExp(r'^(\w+)').firstMatch(remaining);
    if (modeMatch != null) {
      final modeStr = modeMatch.group(1)!;
      remaining = remaining.substring(modeMatch.end).trim();

      switch (modeStr.toUpperCase()) {
        case 'LR':
          mode = ParseMode.LR;
          _parseLRParameters(remaining);
          break;
        case 'JSON':
          mode = ParseMode.JSON;
          _parseJSONParameters(remaining);
          break;
        case 'REGEX':
          mode = ParseMode.Regex;
          _parseRegexParameters(remaining);
          break;
        case 'CSS':
          mode = ParseMode.CSS;
          _parseCSSParameters(remaining);
          break;
      }
    }
  }

  void _parseLRParameters(String remaining) {
    if (remaining.contains('\\"')) {
      final placeholder = '\x00ESCAPED_QUOTE\x00';
      String processed = remaining.replaceAll('\\"', placeholder);

      try {
        // Extract left delimiter
        final leftMatch = RegExp(r'^"([^"]*)"').firstMatch(processed);
        if (leftMatch != null) {
          leftDelim = leftMatch.group(1)!.replaceAll(placeholder, '"');
          processed = processed.substring(leftMatch.end).trim();

          // Extract right delimiter
          final rightMatch = RegExp(r'^"([^"]*)"').firstMatch(processed);
          if (rightMatch != null) {
            rightDelim = rightMatch.group(1)!.replaceAll(placeholder, '"');
            processed = processed.substring(rightMatch.end).trim();

            // Continue with remaining parameters
            _parseCommonParameters(processed.replaceAll(placeholder, '"'));
            return;
          }
        }
      } catch (e) {
        // Ignore error
      }
    }

    if (remaining.contains('":"" """')) {
      final match = RegExp(r'^"([^"]+)":""\s+"""').firstMatch(remaining);
      if (match != null) {
        leftDelim = match.group(1)! + '":"';
        rightDelim = '"';
        remaining = remaining.substring(match.end).trim();
        _parseCommonParameters(remaining);
        return;
      }
    }

    // Handle case where quotes are malformed
    if (remaining.contains('":"" "')) {
      final match = RegExp(r'^"([^"]+)":""\s+"([^"]*)"').firstMatch(remaining);
      if (match != null) {
        leftDelim = match.group(1)! + '":"';
        rightDelim = match.group(2)!;
        remaining = remaining.substring(match.end).trim();
        _parseCommonParameters(remaining);
        return;
      }
    }

    // Standard parsing with LineParser
    try {
      leftDelim = LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);

      rightDelim = LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);
    } catch (e) {
      final matches = RegExp(r'"([^"]*)"').allMatches(remaining).toList();
      if (matches.length >= 2) {
        leftDelim = matches[0].group(1)!;
        rightDelim = matches[1].group(1)!;
        remaining = remaining.substring(matches[1].end).trim();
      } else {
        leftDelim = '';
        rightDelim = '';
      }
    }

    _parseCommonParameters(remaining);
  }

  void _parseJSONParameters(String remaining) {
    // Parse: "jsonPath" [JTokenParsing=True] [Recursive=True] -> VAR/CAP "name"

    // Extract JSON path using LineParser
    try {
      jsonPath = LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);
    } catch (e) {
      // Ignore error
    }

    _parseCommonParameters(remaining);
  }

  void _parseRegexParameters(String remaining) {
    // Parse: "pattern" "output" [DotMatches=True] [CaseSensitive=False] -> VAR/CAP "name"

    // Extract regex pattern using LineParser
    try {
      regex = LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);
    } catch (e) {
      // Ignore error
    }

    try {
      LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);
    } catch (e) {
      // Ignore error
    }

    _parseCommonParameters(remaining);
  }

  void _parseCSSParameters(String remaining) {
    // Parse: "selector" "attribute" [INDEX=0] [Recursive=True] -> VAR/CAP "name"

    // Extract CSS selector using LineParser
    try {
      cssSelector = LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);
    } catch (e) {
      // Ignore error
    }

    // Extract CSS attribute using LineParser
    try {
      cssAttribute = LineParser.parseLiteral(remaining);
      remaining = LineParser.consumeLiteral(remaining);
    } catch (e) {
      // Ignore error
    }

    _parseCommonParameters(remaining);
  }

  void _parseCommonParameters(String remaining) {
    // Parse boolean flags
    final booleanParams = RegExp(r'(\w+)=(True|False)', caseSensitive: false)
        .allMatches(remaining);
    for (final match in booleanParams) {
      final paramName = match.group(1)!.toLowerCase();
      final paramValue = match.group(2)!.toLowerCase() == 'true';

      switch (paramName) {
        case 'recursive':
          recursive = paramValue;
          break;
        case 'encodeoutput':
          encodeOutput = paramValue;
          break;
        case 'createempty':
          createEmpty = paramValue;
          break;
        case 'useregexlr':
          useRegexLR = paramValue;
          break;
        case 'jtokenparsing':
          jTokenParsing = paramValue;
          break;
        case 'dotmatches':
          dotMatches = paramValue;
          break;
        case 'casesensitive':
          caseSensitive = paramValue;
          break;
      }
    }

    final indexMatch =
        RegExp(r'INDEX=(\d+)', caseSensitive: false).firstMatch(remaining);
    if (indexMatch != null) {
      cssIndex = int.tryParse(indexMatch.group(1)!) ?? -1;
    }

    // Parse output directive: -> VAR/CAP "name" ["prefix" "suffix"]
    final arrowIndex = remaining.indexOf('->');
    if (arrowIndex != -1) {
      var outputPart = remaining.substring(arrowIndex + 2).trim();

      // Extract VAR/CAP
      final typeMatch =
          RegExp(r'^(VAR|CAP)\s+', caseSensitive: false).firstMatch(outputPart);
      if (typeMatch != null) {
        outputType = typeMatch.group(1)!.toUpperCase();
        outputPart = outputPart.substring(typeMatch.end);

        // Extract variable name using LineParser
        try {
          outputVariable = LineParser.parseLiteral(outputPart);
          outputPart = LineParser.consumeLiteral(outputPart);

          // Try to extract prefix
          try {
            prefix = LineParser.parseLiteral(outputPart);
            outputPart = LineParser.consumeLiteral(outputPart);

            // Try to extract suffix
            try {
              suffix = LineParser.parseLiteral(outputPart);
            } catch (e) {
              // No suffix
            }
          } catch (e) {
            // No prefix/suffix
          }
        } catch (e) {
          // Ignore error
        }
      }
    }
  }

  @override
  String toLoliCode() {
    final buffer = StringBuffer();

    // Helper function to escape strings for LoliCode output
    String escapeForLoliCode(String value) {
      return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
    }

    // Generate PARSE syntax
    buffer.write(
        'PARSE "${escapeForLoliCode(input)}" ${mode.toString().split('.').last.toUpperCase()}');

    switch (mode) {
      case ParseMode.LR:
        buffer.write(
            ' "${escapeForLoliCode(leftDelim)}" "${escapeForLoliCode(rightDelim)}"');
        if (useRegexLR) buffer.write(' UseRegexLR=True');
        break;
      case ParseMode.JSON:
        buffer.write(' "${escapeForLoliCode(jsonPath)}"');
        if (jTokenParsing) buffer.write(' JTokenParsing=True');
        break;
      case ParseMode.Regex:
        buffer.write(' "${escapeForLoliCode(regex)}" ""');
        if (dotMatches) buffer.write(' DotMatches=True');
        if (!caseSensitive) buffer.write(' CaseSensitive=False');
        break;
      case ParseMode.CSS:
        buffer.write(
            ' "${escapeForLoliCode(cssSelector)}" "${escapeForLoliCode(cssAttribute)}"');
        if (cssIndex >= 0) buffer.write(' INDEX=$cssIndex');
        break;
    }

    // Add common parameters
    if (recursive) buffer.write(' Recursive=True');
    if (encodeOutput) buffer.write(' EncodeOutput=True');
    if (createEmpty) buffer.write(' CreateEmpty=True');

    // Add output directive
    buffer.write(' -> $outputType "${escapeForLoliCode(outputVariable)}"');
    if (prefix.isNotEmpty || suffix.isNotEmpty) {
      buffer.write(
          ' "${escapeForLoliCode(prefix)}" "${escapeForLoliCode(suffix)}"');
    }

    buffer.writeln();
    return buffer.toString();
  }
}
