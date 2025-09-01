import '../variables/variable_pool.dart';
import '../core/bot_data.dart';
import '../variables/variable_types.dart';
import '../variables/variable.dart';

class InterpolationEngine {
  static String interpolate(String input, VariablePool variables,
      [BotData? data, bool escapeForLoliCode = false]) {
    if (input.isEmpty) return input;

    var result = input;
    final regex = RegExp(r'<([^<>]+)>');
    final processedVariables = <String>{};

    while (true) {
      final match = regex.firstMatch(result);
      if (match == null) break;

      final variableExpression = match.group(1)!;

      // Prevent infinite loops by tracking processed variables
      if (processedVariables.contains(variableExpression)) {
        result = result.replaceFirst(match.group(0)!, '');
        continue;
      }

      String replacement = '';

      if (variableExpression.startsWith('COOKIES(') &&
          variableExpression.endsWith(')')) {
        // Cookie variable: <COOKIES(cookieName)>
        final cookieName =
            variableExpression.substring(8, variableExpression.length - 1);
        if (data != null && data.cookies.containsKey(cookieName)) {
          replacement = data.cookies[cookieName]!;
        }
      } else if (variableExpression.startsWith('COOKIES{') &&
          variableExpression.endsWith('}')) {
        // Cookie pattern: <COOKIES{*}> or <COOKIES{pattern}>
        final pattern =
            variableExpression.substring(8, variableExpression.length - 1);
        if (data != null) {
          if (pattern == '*') {
            // Return all cookies as string
            replacement = data.cookies.entries
                .map((e) => '${e.key}=${e.value}')
                .join('; ');
          } else {
            // Find cookies matching pattern
            final matchingCookies = data.cookies.entries
                .where(
                    (e) => e.key.contains(pattern) || e.value.contains(pattern))
                .map((e) => '${e.key}=${e.value}')
                .join('; ');
            replacement = matchingCookies;
          }
        }
      } else {
        // Check for list access: NAME[index] or NAME[*]
        final listMatch =
            RegExp(r'^([^[\]]+)\[([^\]]+)\]$').firstMatch(variableExpression);
        if (listMatch != null) {
          final varName = listMatch.group(1)!;
          final indexStr = listMatch.group(2)!;

          replacement = _handleListAccess(varName, indexStr, variables, data);
        }
        // Check for dictionary key access: NAME(key) or NAME(*)
        else if (variableExpression.contains('(') &&
            variableExpression.endsWith(')')) {
          final dictMatch =
              RegExp(r'^([^()]+)\(([^)]*)\)$').firstMatch(variableExpression);
          if (dictMatch != null) {
            final varName = dictMatch.group(1)!;
            final key = dictMatch.group(2)!;

            replacement =
                _handleDictionaryKeyAccess(varName, key, variables, data);
          }
        }
        // Check for dictionary value access: NAME{value} or NAME{*}
        else if (variableExpression.contains('{') &&
            variableExpression.endsWith('}')) {
          final dictMatch =
              RegExp(r'^([^{}]+)\{([^}]*)\}$').firstMatch(variableExpression);
          if (dictMatch != null) {
            final varName = dictMatch.group(1)!;
            final value = dictMatch.group(2)!;

            replacement =
                _handleDictionaryValueAccess(varName, value, variables, data);
          }
        }
        // Regular variable access
        else {
          if (variableExpression == 'SOURCE' && data != null) {
            replacement = data.responseSource;
            replacement = _escapeForLoliCode(replacement);
            processedVariables.add(variableExpression);
            result = result.replaceFirst(match.group(0)!, replacement);
            break;
          } else if (variableExpression == 'RESPONSECODE' && data != null) {
            replacement = data.responseCode.toString();
            if (data.debugMode) {
              data.log('DEBUG: RESPONSECODE interpolated as: "$replacement"');
            }
          } else if (variableExpression == 'ADDRESS' && data != null) {
            replacement = data.address;
          } else if (variableExpression == 'input' && data != null) {
            replacement = data.input;
          } else {
            final variable = variables.get(variableExpression);
            if (variable != null) {
              replacement = variable.asString();
            }
          }
        }
      }

      if (escapeForLoliCode) {
        replacement = _escapeForLoliCode(replacement);
      }

      processedVariables.add(variableExpression);
      result = result.replaceFirst(match.group(0)!, replacement);
    }

    return result;
  }

  /// Handle list variable access patterns
  static String _handleListAccess(
      String varName, String indexStr, VariablePool variables, BotData? data) {
    final variable = variables.get(varName);
    if (variable == null || variable.type != VariableType.ListOfStrings) {
      return '';
    }

    final listVar = variable as ListVariable;
    final values = listVar.value;

    // Handle wildcard access
    if (indexStr == '*') {
      return values.join(', ');
    }

    // Handle numeric index
    final index = int.tryParse(indexStr);
    if (index != null && index >= 0 && index < values.length) {
      return values[index];
    }

    return '';
  }

  /// Handle dictionary key access patterns
  static String _handleDictionaryKeyAccess(
      String varName, String key, VariablePool variables, BotData? data) {
    final variable = variables.get(varName);
    if (variable == null) {
      if (data?.debugMode ?? false) {
        data?.log('DEBUG: Dictionary variable $varName not found');
      }
      return '';
    }

    if (variable.type != VariableType.DictionaryOfStrings) {
      if (data?.debugMode ?? false) {
        data?.log(
            'DEBUG: Variable $varName is not a dictionary (type: ${variable.type})');
      }
      return '';
    }

    final dictVar = variable as MapVariable;
    final dict = dictVar.value;

    // Handle wildcard access
    if (key == '*') {
      return dict.keys.join(', ');
    }

    // Return value for specific key
    final value = dict[key] ?? '';
    if (data?.debugMode ?? false) {
      data?.log('DEBUG: Dictionary access $varName($key) = "$value"');
    }
    return value;
  }

  /// Handle dictionary value access patterns
  static String _handleDictionaryValueAccess(
      String varName, String value, VariablePool variables, BotData? data) {
    final variable = variables.get(varName);
    if (variable == null || variable.type != VariableType.DictionaryOfStrings) {
      return '';
    }

    final dictVar = variable as MapVariable;
    final dict = dictVar.value;

    // Handle wildcard access
    if (value == '*') {
      return dict.values.join(', ');
    }

    // Find first key with matching value
    for (final entry in dict.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }

    return '';
  }

  /// Escapes content to be safe for use in LoliCode statements
  static String _escapeForLoliCode(String input) {
    return input
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\t', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String interpolateForLoliCode(String input, VariablePool variables,
      [BotData? data]) {
    return interpolate(input, variables, data, true);
  }

  static bool hasInterpolation(String input) {
    return input.contains(RegExp(r'<[^>]+>'));
  }

  static List<String> extractVariableNames(String input) {
    final regex = RegExp(r'<([^>]+)>');
    final matches = regex.allMatches(input);
    return matches.map((match) => match.group(1)!).toList();
  }

  static String interpolateWithFallback(
      String input, VariablePool variables, String fallback) {
    if (input.isEmpty) return input;

    var result = input;
    final regex = RegExp(r'<([^>]+)>');

    while (true) {
      final match = regex.firstMatch(result);
      if (match == null) break;

      final variableName = match.group(1)!;
      final variable = variables.get(variableName);

      String replacement;
      if (variable != null) {
        replacement = variable.asString();
      } else {
        replacement = fallback;
      }

      result = result.replaceFirst(match.group(0)!, replacement);
    }

    return result;
  }

  static String interpolateWithDefaults(
      String input, VariablePool variables, Map<String, String> defaults) {
    if (input.isEmpty) return input;

    var result = input;
    final regex = RegExp(r'<([^>]+)>');

    while (true) {
      final match = regex.firstMatch(result);
      if (match == null) break;

      final variableName = match.group(1)!;
      final variable = variables.get(variableName);

      String replacement;
      if (variable != null) {
        replacement = variable.asString();
      } else if (defaults.containsKey(variableName)) {
        replacement = defaults[variableName]!;
      } else {
        replacement = '<$variableName>';
      }

      result = result.replaceFirst(match.group(0)!, replacement);
    }

    return result;
  }
}
