import 'dart:convert';
import 'dart:typed_data';
import '../core/comparer.dart';

class LineParser {
  static String parseToken(String input) {
    final trimmed = input.trim();
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex == -1) {
      return trimmed;
    }
    return trimmed.substring(0, spaceIndex);
  }

  static String parseLiteral(String input) {
    final trimmed = input.trim();
    if (!trimmed.startsWith('"')) {
      throw FormatException('Literal must start with quote');
    }

    var i = 1;
    final buffer = StringBuffer();

    while (i < trimmed.length) {
      final char = trimmed[i];
      if (char == '"') {
        // End of literal
        return buffer.toString();
      } else if (char == '\\' && i + 1 < trimmed.length) {
        // Escape sequence
        final nextChar = trimmed[i + 1];
        switch (nextChar) {
          case 'n':
            buffer.write('\n');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case 't':
            buffer.write('\t');
            break;
          case '\\':
            buffer.write('\\');
            break;
          case '"':
            buffer.write('"');
            break;
          default:
            buffer.write(nextChar);
        }
        i += 2;
      } else {
        buffer.write(char);
        i++;
      }
    }

    throw FormatException('Unterminated string literal');
  }

  static int parseInt(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^-?\d+').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid integer format');
    }
    return int.parse(match.group(0)!);
  }

  static double parseFloat(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^-?\d*\.?\d+').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid float format');
    }
    return double.parse(match.group(0)!);
  }

  static bool parseBool(String input) {
    final trimmed = input.trim().toLowerCase();
    if (trimmed == 'true') return true;
    if (trimmed == 'false') return false;
    throw FormatException('Invalid boolean format: $trimmed');
  }

  static List<String> parseList(String input) {
    final trimmed = input.trim();
    if (!trimmed.startsWith('[') || !trimmed.endsWith(']')) {
      throw FormatException('List must be enclosed in square brackets');
    }

    final content = trimmed.substring(1, trimmed.length - 1).trim();
    if (content.isEmpty) {
      return [];
    }

    final items = <String>[];
    var i = 0;

    while (i < content.length) {
      // Skip whitespace
      while (i < content.length && content[i] == ' ') {
        i++;
      }

      if (i >= content.length) break;

      if (content[i] == '"') {
        final start = i;
        final literal = parseLiteral(content.substring(i));
        items.add(literal);
        // Find the end of the literal
        i = start + 1;
        while (i < content.length && content[i] != '"') {
          if (content[i] == '\\') i++;
          i++;
        }
        i++;
      } else {
        // Parse unquoted token
        final start = i;
        while (i < content.length && content[i] != ',' && content[i] != ' ') {
          i++;
        }
        items.add(content.substring(start, i));
      }

      // Skip to next comma or end
      while (i < content.length && content[i] != ',') {
        i++;
      }
      if (i < content.length && content[i] == ',') {
        i++;
      }
    }

    return items;
  }

  static Map<String, String> parseMap(String input) {
    final trimmed = input.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) {
      throw FormatException('Dictionary must be enclosed in curly braces');
    }

    final content = trimmed.substring(1, trimmed.length - 1).trim();
    if (content.isEmpty) {
      return {};
    }

    final result = <String, String>{};
    final pairs = content.split(',');

    for (final pair in pairs) {
      final trimmedPair = pair.trim();
      if (trimmedPair.startsWith('(') && trimmedPair.endsWith(')')) {
        // Format: ("key", "value")
        final pairContent = trimmedPair.substring(1, trimmedPair.length - 1);
        final parts = pairContent.split(',');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();
          result[parseLiteral(key)] = parseLiteral(value);
        }
      } else {
        // Format: key:value (JSON style)
        final colonIndex = trimmedPair.indexOf(':');
        if (colonIndex != -1) {
          var key = trimmedPair.substring(0, colonIndex).trim();
          var value = trimmedPair.substring(colonIndex + 1).trim();

          if (key.startsWith('"') && key.endsWith('"') && key.length > 1) {
            key = key.substring(1, key.length - 1);
          }
          if (value.startsWith('"') &&
              value.endsWith('"') &&
              value.length > 1) {
            value = value.substring(1, value.length - 1);
          }

          result[key] = value;
        }
      }
    }

    return result;
  }

  static Uint8List parseByteArray(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return Uint8List(0);
    }

    try {
      // Try base64 decode first
      return base64Decode(trimmed);
    } catch (e) {
      // Fall back to UTF-8 encoding
      return Uint8List.fromList(utf8.encode(trimmed));
    }
  }

  static String consumeToken(String input) {
    final trimmed = input.trim();
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex == -1) {
      return '';
    }
    return trimmed.substring(spaceIndex + 1).trim();
  }

  static String consumeLiteral(String input) {
    final trimmed = input.trim();
    if (!trimmed.startsWith('"')) {
      throw FormatException('Expected literal');
    }

    var i = 1;
    while (i < trimmed.length) {
      final char = trimmed[i];
      if (char == '"') {
        // Found end of literal
        return trimmed.substring(i + 1).trim();
      } else if (char == '\\' && i + 1 < trimmed.length) {
        i += 2;
      } else {
        i++;
      }
    }

    throw FormatException('Unterminated string literal');
  }

  /// Parse a parameter (enum/identifier) argument from the input
  static String parseParameter(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^([A-Za-z][A-Za-z0-9_/\-]*)').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid parameter format');
    }
    return match.group(1)!;
  }

  /// Parse an integer argument
  static int parseNumeric(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^(-?\d+)').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid numeric format');
    }
    return int.parse(match.group(1)!);
  }

  /// Parse a boolean argument (ParamName=True/False)
  static Map<String, bool> parseBoolean(String input) {
    final trimmed = input.trim();
    final match =
        RegExp(r'^([A-Za-z][A-Za-z0-9_]*)=(True|False)', caseSensitive: false)
            .firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid boolean format');
    }
    final paramName = match.group(1)!;
    final value = match.group(2)!.toLowerCase() == 'true';
    return {paramName: value};
  }

  /// Consume a parameter and return the remaining string
  static String consumeParameter(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^([A-Za-z][A-Za-z0-9_/\-]*)').firstMatch(trimmed);
    if (match == null) {
      return trimmed;
    }
    return trimmed.substring(match.group(1)!.length).trim();
  }

  /// Consume an integer value and return the remaining string
  static String consumeNumeric(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^(-?\d+)').firstMatch(trimmed);
    if (match == null) {
      return trimmed;
    }
    return trimmed.substring(match.group(1)!.length).trim();
  }

  /// Consume a boolean value and return the remaining string
  static String consumeBoolean(String input) {
    final trimmed = input.trim();
    final match =
        RegExp(r'^([A-Za-z][A-Za-z0-9_]*)=(True|False)', caseSensitive: false)
            .firstMatch(trimmed);
    if (match == null) {
      return trimmed;
    }
    return trimmed.substring(match.group(0)!.length).trim();
  }

  /// Parse a comparer from the input string
  static Comparer parseComparer(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^([A-Za-z]+)').firstMatch(trimmed);
    if (match == null) {
      return Comparer.equalTo;
    }
    return ComparerExtension.fromString(match.group(1)!);
  }

  /// Consume a comparer and return the remaining string
  static String consumeComparer(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^([A-Za-z]+)').firstMatch(trimmed);
    if (match == null) {
      return trimmed;
    }
    return trimmed.substring(match.group(1)!.length).trim();
  }
}
