import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bullet_droid/shared/models/config_custom_input_values.dart';
import 'package:bullet_droid2/bullet_droid.dart';
import 'package:bullet_droid/core/utils/logging.dart';

final customInputProvider =
    StateNotifierProvider<CustomInputNotifier, ConfigCustomInputValues>((ref) {
      return CustomInputNotifier();
    });

/// Manages per-config custom input values persisted in Hive.
class CustomInputNotifier extends StateNotifier<ConfigCustomInputValues> {
  static const String _boxName = 'custom_input_values';
  Box<ConfigCustomInputValues>? _box;
  final Completer<void> _initCompleter = Completer<void>();

  CustomInputNotifier() : super(ConfigCustomInputValues.empty()) {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      // Check if box is already open, if so reuse it
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<ConfigCustomInputValues>(_boxName);
      } else {
        _box = await Hive.openBox<ConfigCustomInputValues>(_boxName);
      }

      final stored = _box?.get('values');
      if (stored != null) {
        // Ensure proper type conversion when reading from Hive
        final safeValues = Map<String, Map<String, String>>.from(
          stored.values.map(
            (k, v) => MapEntry(k.toString(), Map<String, String>.from(v)),
          ),
        );
        state = ConfigCustomInputValues(values: safeValues);
      }
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    } catch (e) {
      Log.w('Error initializing CustomInputProvider: $e');
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete(); // Unblock dependents even on error
      }
    }
  }

  /// Ensure the provider is initialized before performing operations
  Future<void> _ensureInitialized() async => _initCompleter.future;

  Future<void> ensureInitialized() => _ensureInitialized();

  /// Get custom input value for a specific config and variable
  Future<String?> getCustomInputValue(
    String configId,
    String variableName,
  ) async {
    await _ensureInitialized();
    return state.getCustomInputValue(configId, variableName);
  }

  /// Set custom input value for a specific config and variable
  Future<void> setCustomInputValue(
    String configId,
    String variableName,
    String value,
  ) async {
    await _ensureInitialized();
    final newState = ConfigCustomInputValues(
      values: Map<String, Map<String, String>>.from(
        state.values.map(
          (k, v) => MapEntry(k.toString(), Map<String, String>.from(v)),
        ),
      ),
    );
    newState.setCustomInputValue(configId, variableName, value);
    state = newState;
    await _saveToHive();
  }

  /// Clear all custom input values for a specific config
  Future<void> clearConfigValues(String configId) async {
    await _ensureInitialized();
    final newState = ConfigCustomInputValues(
      values: Map<String, Map<String, String>>.from(
        state.values.map(
          (k, v) => MapEntry(k.toString(), Map<String, String>.from(v)),
        ),
      ),
    );
    newState.clearConfigValues(configId);
    state = newState;
    await _saveToHive();
  }

  /// Get all custom input values for a specific config
  Future<Map<String, String>> getConfigValues(String configId) async {
    await _ensureInitialized();
    return state.getConfigValues(configId);
  }

  /// Check if all required custom inputs have values for a config
  Future<bool> validateConfigInputs(
    String configId,
    List<CustomInput> customInputs,
  ) async {
    await _ensureInitialized();
    final requiredVariableNames = customInputs
        .where((input) => input.isRequired)
        .map((input) => input.variableName)
        .toList();
    return state.validateConfigInputs(configId, requiredVariableNames);
  }

  /// Get missing required custom input variable names for a config
  Future<List<String>> getMissingRequiredInputs(
    String configId,
    List<CustomInput> customInputs,
  ) async {
    await _ensureInitialized();
    final requiredVariableNames = customInputs
        .where((input) => input.isRequired)
        .map((input) => input.variableName)
        .toList();
    return state.getMissingRequiredInputs(configId, requiredVariableNames);
  }

  /// Get custom input values formatted for JobParams
  Future<Map<String, dynamic>> getCustomInputsForJob(String configId) async {
    await _ensureInitialized();
    final configValues = state.getConfigValues(configId);
    return Map<String, dynamic>.from(configValues);
  }

  String? getCustomInputValueSync(String configId, String variableName) {
    return state.getCustomInputValue(configId, variableName);
  }

  void setCustomInputValueSync(
    String configId,
    String variableName,
    String value,
  ) {
    final newState = ConfigCustomInputValues(
      values: Map<String, Map<String, String>>.from(
        state.values.map(
          (k, v) => MapEntry(k.toString(), Map<String, String>.from(v)),
        ),
      ),
    );
    newState.setCustomInputValue(configId, variableName, value);
    state = newState;
    _saveToHive();
  }

  Future<void> _saveToHive() async {
    try {
      await _box?.put('values', state);
    } catch (e) {
      Log.w('Error saving custom input values: $e');
    }
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}
