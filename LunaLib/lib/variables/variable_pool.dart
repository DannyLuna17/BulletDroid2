import 'dart:typed_data';
import 'variable.dart';
import 'variable_types.dart';
import '../core/comparer.dart';
import '../core/condition.dart';
import '../core/bot_data.dart';

class VariablePool {
  final Map<String, Variable> _variables = {};

  Variable? get(String name) => _variables[name];

  void set(Variable variable) {
    _variables[variable.name] = variable;
  }

  void setByName(String name, dynamic value) {
    if (_variables.containsKey(name)) {
      // Update existing variable with new value while preserving type and capture status
      final existing = _variables[name]!;
      final newVar = _createVariableOfSameType(existing, value);
      newVar.markedForCapture = existing.markedForCapture;
      _variables[name] = newVar;
    } else {
      // Create new variable
      final newVar = _createVariableFromValue(name, value);
      _variables[name] = newVar;
    }
  }

  bool exists(String name) => _variables.containsKey(name);

  void remove(String name) => _variables.remove(name);

  void clear() => _variables.clear();

  /// Remove variables by condition
  void removeByCondition(Comparer comparer, String pattern, BotData data) {
    final toRemove = <String>[];

    // Find all variables that match the condition
    for (final entry in _variables.entries) {
      if (Condition.evaluateWithData(entry.key, comparer, pattern, data)) {
        toRemove.add(entry.key);
      }
    }

    // Remove matching variables
    for (final key in toRemove) {
      _variables.remove(key);
    }
  }

  List<Variable> getAll() => _variables.values.toList();

  List<Variable> getMarkedForCapture() {
    return _variables.values.where((v) => v.markedForCapture).toList();
  }

  Map<String, dynamic> getCapturedValues() {
    final result = <String, dynamic>{};
    for (final variable in getMarkedForCapture()) {
      result[variable.name] = variable.asObject();
    }
    return result;
  }

  void markForCapture(String name) {
    final variable = _variables[name];
    if (variable != null) {
      variable.markedForCapture = true;
    }
  }

  void unmarkForCapture(String name) {
    final variable = _variables[name];
    if (variable != null) {
      variable.markedForCapture = false;
    }
  }

  void setCapture(String name, dynamic value) {
    setByName(name, value);
    markForCapture(name);
  }

  List<String> getVariableNames() => _variables.keys.toList();

  int get count => _variables.length;

  Variable _createVariableOfSameType(Variable existing, dynamic value) {
    switch (existing.type) {
      case VariableType.String:
        return StringVariable(existing.name, value.toString());
      case VariableType.Int:
        return IntVariable(
            existing.name, value is int ? value : int.parse(value.toString()));
      case VariableType.Float:
        return FloatVariable(existing.name,
            value is double ? value : double.parse(value.toString()));
      case VariableType.Bool:
        return BoolVariable(existing.name,
            value is bool ? value : value.toString().toLowerCase() == 'true');
      case VariableType.ListOfStrings:
        if (value is List<String>) {
          return ListVariable(existing.name, value);
        } else if (value is List) {
          return ListVariable(
              existing.name, value.map((e) => e.toString()).toList());
        } else {
          return ListVariable(existing.name, [value.toString()]);
        }
      case VariableType.DictionaryOfStrings:
        if (value is Map<String, String>) {
          return MapVariable(existing.name, value);
        } else if (value is Map) {
          final stringMap = <String, String>{};
          value.forEach((key, val) {
            stringMap[key.toString()] = val.toString();
          });
          return MapVariable(existing.name, stringMap);
        } else {
          return MapVariable(existing.name, {value.toString(): ''});
        }
      case VariableType.ByteArray:
        if (value is Uint8List) {
          return ByteArrayVariable(existing.name, value);
        } else {
          return ByteArrayVariable(
              existing.name, Uint8List.fromList(value.toString().codeUnits));
        }
    }
  }

  Variable _createVariableFromValue(String name, dynamic value) {
    if (value is String) {
      return StringVariable(name, value);
    } else if (value is int) {
      return IntVariable(name, value);
    } else if (value is double) {
      return FloatVariable(name, value);
    } else if (value is bool) {
      return BoolVariable(name, value);
    } else if (value is List<String>) {
      return ListVariable(name, value);
    } else if (value is Map<String, String>) {
      return MapVariable(name, value);
    } else if (value is Uint8List) {
      return ByteArrayVariable(name, value);
    } else if (value is List) {
      return ListVariable(name, value.map((e) => e.toString()).toList());
    } else if (value is Map) {
      final stringMap = <String, String>{};
      value.forEach((key, val) {
        stringMap[key.toString()] = val.toString();
      });
      return MapVariable(name, stringMap);
    } else {
      return StringVariable(name, value.toString());
    }
  }
}
