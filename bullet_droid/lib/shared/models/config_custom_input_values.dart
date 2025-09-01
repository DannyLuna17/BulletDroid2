import 'package:hive_flutter/hive_flutter.dart';

part 'config_custom_input_values.g.dart';

@HiveType(typeId: 3)
class ConfigCustomInputValues extends HiveObject {
  @HiveField(0)
  Map<String, Map<String, String>> values;

  ConfigCustomInputValues({required this.values});

  ConfigCustomInputValues.empty() : values = {};

  /// Get custom input value for a specific config and variable
  String? getCustomInputValue(String configId, String variableName) {
    return values[configId]?[variableName];
  }

  /// Set custom input value for a specific config and variable
  void setCustomInputValue(String configId, String variableName, String value) {
    values[configId] ??= {};
    values[configId]![variableName] = value;
  }

  /// Clear all custom input values for a specific config
  void clearConfigValues(String configId) {
    values.remove(configId);
  }

  /// Get all custom input values for a specific config
  Map<String, String> getConfigValues(String configId) {
    return values[configId] ?? {};
  }

  /// Check if all required custom inputs have values for a config
  bool validateConfigInputs(
    String configId,
    List<String> requiredVariableNames,
  ) {
    final configValues = values[configId] ?? {};
    for (final variableName in requiredVariableNames) {
      final value = configValues[variableName];
      if (value == null || value.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Get missing required custom input variable names for a config
  List<String> getMissingRequiredInputs(
    String configId,
    List<String> requiredVariableNames,
  ) {
    final configValues = values[configId] ?? {};
    final missing = <String>[];
    for (final variableName in requiredVariableNames) {
      final value = configValues[variableName];
      if (value == null || value.trim().isEmpty) {
        missing.add(variableName);
      }
    }
    return missing;
  }
}
