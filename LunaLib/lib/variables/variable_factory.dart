import 'dart:typed_data';
import 'variable.dart';
import 'variable_types.dart';

class VariableFactory {
  static Variable fromObject(String name, dynamic obj) {
    if (obj is String) {
      return StringVariable(name, obj);
    } else if (obj is int) {
      return IntVariable(name, obj);
    } else if (obj is double) {
      return FloatVariable(name, obj);
    } else if (obj is bool) {
      return BoolVariable(name, obj);
    } else if (obj is List<String>) {
      return ListVariable(name, obj);
    } else if (obj is Map<String, String>) {
      return MapVariable(name, obj);
    } else if (obj is Uint8List) {
      return ByteArrayVariable(name, obj);
    } else if (obj is List) {
      // Convert generic list to List<String>
      return ListVariable(name, obj.map((e) => e.toString()).toList());
    } else if (obj is Map) {
      // Convert generic map to Map<String, String>
      final stringMap = <String, String>{};
      obj.forEach((key, value) {
        stringMap[key.toString()] = value.toString();
      });
      return MapVariable(name, stringMap);
    } else {
      // Default to string representation
      return StringVariable(name, obj.toString());
    }
  }

  static Variable fromString(String name, String value, VariableType type) {
    switch (type) {
      case VariableType.String:
        return StringVariable(name, value);
      case VariableType.Int:
        return IntVariable(name, int.parse(value));
      case VariableType.Float:
        return FloatVariable(name, double.parse(value));
      case VariableType.Bool:
        return BoolVariable(name, value.toLowerCase() == 'true');
      case VariableType.ListOfStrings:
        // Parse simple list format: [item1, item2, item3]
        if (value.startsWith('[') && value.endsWith(']')) {
          final content = value.substring(1, value.length - 1);
          if (content.trim().isEmpty) {
            return ListVariable(name, []);
          }
          final items = content.split(',').map((e) => e.trim()).toList();
          return ListVariable(name, items);
        }
        return ListVariable(name, [value]);
      case VariableType.DictionaryOfStrings:
        // Parse simple dict format: {key1:value1, key2:value2}
        if (value.startsWith('{') && value.endsWith('}')) {
          final content = value.substring(1, value.length - 1);
          final map = <String, String>{};
          if (content.trim().isNotEmpty) {
            final pairs = content.split(',');
            for (final pair in pairs) {
              final parts = pair.split(':');
              if (parts.length == 2) {
                map[parts[0].trim()] = parts[1].trim();
              }
            }
          }
          return MapVariable(name, map);
        }
        return MapVariable(name, {value: ''});
      case VariableType.ByteArray:
        // Assume base64 encoded string
        try {
          final bytes = Uint8List.fromList(value.codeUnits);
          return ByteArrayVariable(name, bytes);
        } catch (e) {
          return ByteArrayVariable(name, Uint8List.fromList(value.codeUnits));
        }
    }
  }

  static VariableType detectType(String value) {
    // Try to detect the most appropriate type
    if (value.toLowerCase() == 'true' || value.toLowerCase() == 'false') {
      return VariableType.Bool;
    }

    if (int.tryParse(value) != null) {
      return VariableType.Int;
    }

    if (double.tryParse(value) != null) {
      return VariableType.Float;
    }

    if (value.startsWith('[') && value.endsWith(']')) {
      return VariableType.ListOfStrings;
    }

    if (value.startsWith('{') && value.endsWith('}')) {
      return VariableType.DictionaryOfStrings;
    }

    return VariableType.String;
  }
}
