import 'dart:io';
import 'config_settings.dart';
import 'app_configuration.dart';
import '../variables/variable_pool.dart';

/// Handles custom input prompts for CustomInputs
class CustomInputHandler {
  /// Process custom inputs from config settings and prompt user if enabled
  static Future<void> processCustomInputs(
      ConfigSettings settings, VariablePool variables) async {
    if (!AppConfiguration.enableCustomInputs || settings.customInputs.isEmpty) {
      return;
    }

    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print(
          'This config requires ${settings.customInputs.length} custom input(s):\n');
    }

    for (final input in settings.customInputs) {
      await _promptForInput(input, variables);
    }

    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print('\n All custom inputs collected!\n');
    }
  }

  /// Prompt user for a single custom input
  static Future<void> _promptForInput(
      CustomInput input, VariablePool variables) async {
    // Display input information
    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print('Variable: ${input.variableName}');
    }
    if (input.description.isNotEmpty) {
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('Description: ${input.description}');
      }
    }

    // Check if variable already exists
    if (variables.exists(input.variableName)) {
      final existingValue = variables.get(input.variableName)?.asString() ?? '';
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('Current value: $existingValue');
        // ignore: avoid_print
        print('Press Enter to keep current value, or type new value:');
      }
    } else {
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('Enter value:');
      }
    }

    stdout.write('   > ');

    // Read user input
    final userInput = stdin.readLineSync() ?? '';

    // Set the variable
    if (userInput.trim().isNotEmpty) {
      variables.setByName(input.variableName, userInput.trim());
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('Set ${input.variableName} = "${userInput.trim()}"');
      }
    } else if (!variables.exists(input.variableName)) {
      // Set empty value if no existing value and no input provided
      variables.setByName(input.variableName, '');
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('Set ${input.variableName} = "" (empty)');
      }
    } else {
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('Kept existing value');
      }
    }

    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print('');
    }
  }

  /// Set default values for custom inputs without prompting
  static void setDefaultCustomInputs(
      ConfigSettings settings, VariablePool variables) {
    for (final input in settings.customInputs) {
      if (!variables.exists(input.variableName)) {
        variables.setByName(input.variableName, '');
      }
    }
  }

  /// Display custom inputs information
  static void displayCustomInputsInfo(ConfigSettings settings) {
    if (settings.customInputs.isEmpty) {
      return;
    }

    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print('\nCustom Inputs Available:');
    }
    for (final input in settings.customInputs) {
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print('${input.variableName}: ${input.description}');
      }
    }

    if (!AppConfiguration.enableCustomInputs) {
      if (AppConfiguration.debugMode) {
        // ignore: avoid_print
        print(
            'Enable custom inputs in AppConfiguration to enable interactive prompts');
      }
    }
    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print('');
    }
  }
}
