import '../base/block_instance.dart';
import '../../core/bot_data.dart';
import '../../core/status.dart';
import '../../parsing/interpolation_engine.dart';

enum KeychainMode { AND, OR }

class KeycheckBlock extends BlockInstance {
  List<Keychain> keychains = [];
  bool banOn4XX = false;
  bool banOnToCheck = true;

  KeycheckBlock() : super(id: 'Keycheck');

  @override
  Future<void> execute(BotData data) async {
    try {
      // Check for 4XX ban condition first
      if (banOn4XX && data.responseCode >= 400 && data.responseCode < 500) {
        data.status = BotStatus.BAN;
        data.log(
            'KEYCHECK: Banned due to 4XX response code (${data.responseCode})');
        return;
      }

      for (final keychain in keychains) {
        final result = _evaluateKeychain(keychain, data);
        if (result) {
          // Set the status based on keychain result
          switch (keychain.resultStatus.toUpperCase()) {
            case 'SUCCESS':
              data.status = BotStatus.SUCCESS;
              break;
            case 'FAIL':
            case 'FAILURE':
              data.status = BotStatus.FAIL;
              break;
            case 'RETRY':
              data.status = BotStatus.RETRY;
              break;
            case 'BAN':
              data.status = BotStatus.BAN;
              break;
            case 'CUSTOM':
              data.status = BotStatus.CUSTOM;
              break;
            default:
              // Handle custom status names
              if (keychain.resultStatus.isNotEmpty) {
                data.status = BotStatus.CUSTOM;
                data.customStatus = keychain.resultStatus;
              } else {
                data.status = BotStatus.NONE;
              }
          }

          final statusText = keychain.customName.isNotEmpty
              ? '${keychain.resultStatus} "${keychain.customName}"'
              : keychain.resultStatus;
          data.log('Keychain matched: $statusText');
          return;
        }
      }

      data.log('No keychain matched');

      // If banOnToCheck is enabled and no keychain matched, ban the proxy and set status to TOCHECK
      if (banOnToCheck && !banOn4XX) {
        data.proxyBanned = true;
        data.status = BotStatus.TOCHECK;
        // data.log(
        //     'KEYCHECK: BAN keychain matched with BanOnToCheck=True: Proxy will be banned, status set to TOCHECK');
      }

    } catch (e) {
      data.log('Keycheck failed: $e');
      throw e;
    }
  }

  bool _evaluateKeychain(Keychain keychain, BotData data) {
    if (keychain.keys.isEmpty) return false;

    final results = <bool>[];

    for (final key in keychain.keys) {
      final result = _evaluateKey(key, data);
      results.add(result);
    }

    // Apply AND/OR logic
    switch (keychain.mode) {
      case KeychainMode.AND:
        return results.every((r) => r);
      case KeychainMode.OR:
        return results.any((r) => r);
    }
  }

  bool _evaluateKey(Key key, BotData data) {
    switch (key.type) {
      case KeyType.STRING:
        return _evaluateStringKey(key as StringKey, data);
      case KeyType.INT:
        return _evaluateIntKey(key as IntKey, data);
      case KeyType.BOOL:
        return _evaluateBoolKey(key as BoolKey, data);
    }
  }

  bool _evaluateStringKey(StringKey key, BotData data) {
    final left =
        InterpolationEngine.interpolate(key.left, data.variables, data);
    final right =
        InterpolationEngine.interpolate(key.right, data.variables, data);

    bool result;
    switch (key.comparison) {
      case StringComparison.Contains:
        result = left.contains(right);
        break;
      case StringComparison.DoesNotContain:
        result = !left.contains(right);
        break;
      case StringComparison.EqualTo:
        result = left == right;
        break;
      case StringComparison.NotEqualTo:
        result = left != right;
        break;
      case StringComparison.StartsWith:
        result = left.startsWith(right);
        break;
      case StringComparison.EndsWith:
        result = left.endsWith(right);
        break;
    }

    if (data.debugMode) {
      data.log(
          'KEYCHECK: Evaluating "${key.comparison}" - left contains "${left.length > 100 ? left.substring(0, 100) + "..." : left}" ${key.comparison} right="${right}" = $result');
    }

    return result;
  }

  bool _evaluateIntKey(IntKey key, BotData data) {
    try {
      final left =
          int.parse(InterpolationEngine.interpolate(key.left, data.variables));
      final right =
          int.parse(InterpolationEngine.interpolate(key.right, data.variables));

      switch (key.comparison) {
        case IntComparison.EqualTo:
          return left == right;
        case IntComparison.NotEqualTo:
          return left != right;
        case IntComparison.GreaterThan:
          return left > right;
        case IntComparison.LessThan:
          return left < right;
        case IntComparison.GreaterThanOrEqualTo:
          return left >= right;
        case IntComparison.LessThanOrEqualTo:
          return left <= right;
      }
    } catch (e) {
      return false;
    }
  }

  bool _evaluateBoolKey(BoolKey key, BotData data) {
    try {
      final left = InterpolationEngine.interpolate(key.left, data.variables)
              .toLowerCase() ==
          'true';
      final right = InterpolationEngine.interpolate(key.right, data.variables)
              .toLowerCase() ==
          'true';

      switch (key.comparison) {
        case BoolComparison.EqualTo:
          return left == right;
        case BoolComparison.NotEqualTo:
          return left != right;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  void fromLoliCode(String content) {
    final lines = content.split('\n');

    Keychain? currentKeychain;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Parse top-level KEYCHECK parameters
      if (trimmed.startsWith('KEYCHECK ')) {
        final paramsLine = trimmed.substring(9).trim();
        _parseKeycheckParameters(paramsLine);
        continue;
      }

      if (trimmed.startsWith('KEYCHAIN ')) {
        // Parse keychain header: KEYCHAIN SUCCESS OR or KEYCHAIN CUSTOM "DEFAULT" OR
        final parts = trimmed.split(' ');
        if (parts.length >= 3) {
          currentKeychain = Keychain();
          currentKeychain.resultStatus = parts[1];

          // Check for CUSTOM with custom name
          if (parts[1].toUpperCase() == 'CUSTOM' && parts.length >= 4) {
            // Extract custom name from quotes
            var customNamePart = parts[2];
            var modeIndex = 3;
            if (customNamePart.startsWith('"')) {
              // Handle quoted custom name
              if (customNamePart.endsWith('"')) {
                // Single word custom name
                currentKeychain.customName =
                    customNamePart.substring(1, customNamePart.length - 1);
              } else {
                // Multi-word custom name - reconstruct
                final customNameParts = <String>[customNamePart.substring(1)];
                for (var i = 3; i < parts.length; i++) {
                  if (parts[i].endsWith('"')) {
                    customNameParts
                        .add(parts[i].substring(0, parts[i].length - 1));
                    modeIndex = i + 1;
                    break;
                  } else {
                    customNameParts.add(parts[i]);
                  }
                }
                currentKeychain.customName = customNameParts.join(' ');
              }
            }

            if (modeIndex < parts.length) {
              currentKeychain.mode = parts[modeIndex] == 'AND'
                  ? KeychainMode.AND
                  : KeychainMode.OR;
            }
          } else {
            // Regular keychain mode
            currentKeychain.mode =
                parts[2] == 'AND' ? KeychainMode.AND : KeychainMode.OR;
          }

          keychains.add(currentKeychain);
        }
      } else if (trimmed.startsWith('STRINGKEY ') && currentKeychain != null) {
        // Parse string key
        final keyContent = trimmed.substring(10);
        final key = _parseStringKey(keyContent);
        currentKeychain.keys.add(key);
      } else if (trimmed.startsWith('INTKEY ') && currentKeychain != null) {
        // Parse int key
        final keyContent = trimmed.substring(7);
        final key = _parseIntKey(keyContent);
        currentKeychain.keys.add(key);
      } else if (trimmed.startsWith('BOOLKEY ') && currentKeychain != null) {
        // Parse bool key
        final keyContent = trimmed.substring(8);
        final key = _parseBoolKey(keyContent);
        currentKeychain.keys.add(key);
      } else if (trimmed.startsWith('KEY ') && currentKeychain != null) {
        final keyContent = trimmed.substring(4).trim();
        final key = _parseSimpleKey(keyContent);
        currentKeychain.keys.add(key);
      }
    }
  }

  void _parseKeycheckParameters(String paramsLine) {
    // Parse parameters like: BanOn4XX=True BanOnToCheck=False
    final paramMatches = RegExp(r'(\w+)=(True|False)', caseSensitive: false)
        .allMatches(paramsLine);

    for (final match in paramMatches) {
      final paramName = match.group(1)!.toLowerCase();
      final paramValue = match.group(2)!.toLowerCase() == 'true';

      switch (paramName) {
        case 'banon4xx':
          banOn4XX = paramValue;
          break;
        case 'banontocheck':
          banOnToCheck = paramValue;
          break;
      }
    }
  }

  StringKey _parseStringKey(String content) {
    // Simple parsing: left comparison right
    final parts = content.split(' ');
    final key = StringKey();
    if (parts.length >= 3) {
      key.left = parts[0];
      key.comparison = _parseStringComparison(parts[1]);
      key.right = parts.sublist(2).join(' ');
    }
    return key;
  }

  IntKey _parseIntKey(String content) {
    final parts = content.split(' ');
    final key = IntKey();
    if (parts.length >= 3) {
      key.left = parts[0];
      key.comparison = _parseIntComparison(parts[1]);
      key.right = parts[2];
    }
    return key;
  }

  BoolKey _parseBoolKey(String content) {
    final parts = content.split(' ');
    final key = BoolKey();
    if (parts.length >= 3) {
      key.left = parts[0];
      key.comparison = _parseBoolComparison(parts[1]);
      key.right = parts[2];
    }
    return key;
  }

  StringKey _parseSimpleKey(String content) {
    final key = StringKey();

    // Check for the extended syntax with explicit left/comparison/right
    if (content.contains('" ') &&
        (content.contains('Contains') ||
            content.contains('DoesNotContain') ||
            content.contains('EqualTo') ||
            content.contains('NotEqualTo') ||
            content.contains('StartsWith') ||
            content.contains('EndsWith'))) {
      // First, extract the left side (variable reference)
      final leftMatch = RegExp(r'^"([^"]*)"').firstMatch(content);
      if (leftMatch != null) {
        key.left = leftMatch.group(1)!;
        var remaining = content.substring(leftMatch.end).trim();

        // Extract comparison operator
        final compMatch = RegExp(r'^(\w+)').firstMatch(remaining);
        if (compMatch != null) {
          final compStr = compMatch.group(1)!;
          key.comparison = _parseStringComparisonFromKeyword(compStr);
          remaining = remaining.substring(compMatch.end).trim();

          // Extract right side pattern
          if (remaining.startsWith('"') && remaining.endsWith('"')) {
            var pattern = remaining.substring(1, remaining.length - 1);
            pattern = pattern.replaceAll(r'\"', '"');
            key.right = pattern;
          } else {
            key.right = remaining;
          }
        }
      }
    } else {
      // Simple syntax: KEY "pattern"
      key.left = '<SOURCE>'; // Default to checking against response source
      key.comparison = StringComparison.Contains; // Default comparison

      // Extract pattern and unescape quotes
      if (content.startsWith('"') && content.endsWith('"')) {
        var pattern = content.substring(1, content.length - 1);
        pattern = pattern.replaceAll(r'\"', '"');
        key.right = pattern;
      } else {
        key.right = content;
      }
    }

    return key;
  }

  StringComparison _parseStringComparison(String comp) {
    switch (comp.toLowerCase()) {
      case 'contains':
        return StringComparison.Contains;
      case 'doesnotcontain':
        return StringComparison.DoesNotContain;
      case 'equalto':
        return StringComparison.EqualTo;
      case 'notequalto':
        return StringComparison.NotEqualTo;
      case 'startswith':
        return StringComparison.StartsWith;
      case 'endswith':
        return StringComparison.EndsWith;
      default:
        return StringComparison.Contains;
    }
  }

  IntComparison _parseIntComparison(String comp) {
    switch (comp.toLowerCase()) {
      case 'equalto':
        return IntComparison.EqualTo;
      case 'notequalto':
        return IntComparison.NotEqualTo;
      case 'greaterthan':
        return IntComparison.GreaterThan;
      case 'lessthan':
        return IntComparison.LessThan;
      case 'greaterthanorequalto':
        return IntComparison.GreaterThanOrEqualTo;
      case 'lessthanorequalto':
        return IntComparison.LessThanOrEqualTo;
      default:
        return IntComparison.EqualTo;
    }
  }

  BoolComparison _parseBoolComparison(String comp) {
    switch (comp.toLowerCase()) {
      case 'equalto':
        return BoolComparison.EqualTo;
      case 'notequalto':
        return BoolComparison.NotEqualTo;
      default:
        return BoolComparison.EqualTo;
    }
  }

  StringComparison _parseStringComparisonFromKeyword(String keyword) {
    switch (keyword) {
      case 'Contains':
        return StringComparison.Contains;
      case 'DoesNotContain':
        return StringComparison.DoesNotContain;
      case 'EqualTo':
      case 'Equals':
        return StringComparison.EqualTo;
      case 'NotEqualTo':
      case 'DoesNotEqual':
        return StringComparison.NotEqualTo;
      case 'StartsWith':
        return StringComparison.StartsWith;
      case 'EndsWith':
        return StringComparison.EndsWith;
      default:
        return StringComparison.Contains;
    }
  }

  @override
  String toLoliCode() {
    final buffer = StringBuffer();

    if (banOn4XX || !banOnToCheck) {
      buffer.write('KEYCHECK');
      if (banOn4XX) buffer.write(' BanOn4XX=True');
      if (!banOnToCheck) buffer.write(' BanOnToCheck=False');
      buffer.writeln();
    }

    for (final keychain in keychains) {
      if (keychain.resultStatus.toUpperCase() == 'CUSTOM' &&
          keychain.customName.isNotEmpty) {
        buffer.writeln(
            'KEYCHAIN ${keychain.resultStatus} "${keychain.customName}" ${keychain.mode.toString().split('.').last}');
      } else {
        buffer.writeln(
            'KEYCHAIN ${keychain.resultStatus} ${keychain.mode.toString().split('.').last}');
      }

      for (final key in keychain.keys) {
        switch (key.type) {
          case KeyType.STRING:
            final stringKey = key as StringKey;
            buffer.writeln(
                '  STRINGKEY ${stringKey.left} ${stringKey.comparison.toString().split('.').last} ${stringKey.right}');
            break;
          case KeyType.INT:
            final intKey = key as IntKey;
            buffer.writeln(
                '  INTKEY ${intKey.left} ${intKey.comparison.toString().split('.').last} ${intKey.right}');
            break;
          case KeyType.BOOL:
            final boolKey = key as BoolKey;
            buffer.writeln(
                '  BOOLKEY ${boolKey.left} ${boolKey.comparison.toString().split('.').last} ${boolKey.right}');
            break;
        }
      }
    }

    return buffer.toString();
  }
}

class Keychain {
  String resultStatus = 'SUCCESS';
  KeychainMode mode = KeychainMode.OR;
  List<Key> keys = [];
  String customName = '';
}

enum KeyType { STRING, INT, BOOL }

abstract class Key {
  KeyType get type;
}

class StringKey extends Key {
  String left = '';
  StringComparison comparison = StringComparison.Contains;
  String right = '';

  @override
  KeyType get type => KeyType.STRING;
}

class IntKey extends Key {
  String left = '';
  IntComparison comparison = IntComparison.EqualTo;
  String right = '';

  @override
  KeyType get type => KeyType.INT;
}

class BoolKey extends Key {
  String left = '';
  BoolComparison comparison = BoolComparison.EqualTo;
  String right = '';

  @override
  KeyType get type => KeyType.BOOL;
}

enum StringComparison {
  Contains,
  EqualTo,
  NotEqualTo,
  StartsWith,
  EndsWith,
  DoesNotContain
}

enum IntComparison {
  EqualTo,
  NotEqualTo,
  GreaterThan,
  LessThan,
  GreaterThanOrEqualTo,
  LessThanOrEqualTo
}

enum BoolComparison { EqualTo, NotEqualTo }
