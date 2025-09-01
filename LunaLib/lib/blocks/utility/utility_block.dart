import 'dart:convert';
import '../base/block_instance.dart';
import '../../core/bot_data.dart';
import '../../parsing/interpolation_engine.dart';
import '../../variables/variable_factory.dart';
import '../../variables/variable.dart';
import '../../services/file_system_service.dart';

enum UtilityOperationType { LIST, VARIABLE, CONVERSION, FILE }

enum ListAction { JOIN, SPLIT, ADD, REMOVE, CLEAR, COUNT }

enum VariableAction {
  SPLIT,
  JOIN,
  REPLACE,
  SUBSTRING,
  TOUPPER,
  TOLOWER,
  LENGTH
}

enum ConversionAction { BASE64, HEX, URL, HTML, JSON }

enum FileAction { READ, WRITE, APPEND, DELETE, EXISTS }

class UtilityBlock extends BlockInstance {
  UtilityOperationType operationType = UtilityOperationType.LIST;
  String targetName = '';
  String action = '';
  List<String> parameters = [];
  String outputType = 'VAR'; // VAR or CAP
  String outputVariable = '';

  UtilityBlock() : super(id: 'Utility');

  @override
  Future<void> execute(BotData data) async {
    try {
      String result = '';

      switch (operationType) {
        case UtilityOperationType.LIST:
          result = await _executeListOperation(data);
          break;
        case UtilityOperationType.VARIABLE:
          result = await _executeVariableOperation(data);
          break;
        case UtilityOperationType.CONVERSION:
          result = await _executeConversionOperation(data);
          break;
        case UtilityOperationType.FILE:
          result = await _executeFileOperation(data);
          break;
      }

      // Store result if output variable is specified
      if (outputVariable.isNotEmpty) {
        final variable = VariableFactory.fromObject(outputVariable, result);
        data.variables.set(variable);

        if (outputType == 'CAP') {
          data.variables.markForCapture(outputVariable);
        }

        data.log(
            'UTILITY ${operationType.toString().split('.').last} $action: Set $outputType $outputVariable = "$result"');
      }
    } catch (e) {
      data.log('UTILITY operation failed: $e');
      throw e;
    }
  }

  Future<String> _executeListOperation(BotData data) async {
    final interpolatedTarget =
        InterpolationEngine.interpolate(targetName, data.variables, data);
    final targetVar = data.variables.get(interpolatedTarget);

    switch (action.toUpperCase()) {
      case 'JOIN':
        if (targetVar != null && targetVar is ListVariable) {
          final separator = parameters.isNotEmpty
              ? InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)
              : ',';
          return targetVar.value.join(separator);
        }
        return '';

      case 'SPLIT':
        // Convert string variable to list
        if (targetVar != null) {
          final separator = parameters.isNotEmpty
              ? InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)
              : ',';
          final stringValue = targetVar.asString();
          final splitResult = stringValue.split(separator);

          // Update the original variable to be a list
          final listVar =
              VariableFactory.fromObject(interpolatedTarget, splitResult);
          data.variables.set(listVar);

          return splitResult.length.toString();
        }
        return '0';

      case 'ADD':
        if (targetVar != null && targetVar is ListVariable) {
          final valueToAdd = parameters.isNotEmpty
              ? InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)
              : '';
          targetVar.value.add(valueToAdd);
          return targetVar.value.length.toString();
        }
        return '0';

      case 'REMOVE':
        if (targetVar != null && targetVar is ListVariable) {
          final valueToRemove = parameters.isNotEmpty
              ? InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)
              : '';
          targetVar.value.remove(valueToRemove);
          return targetVar.value.length.toString();
        }
        return '0';

      case 'CLEAR':
        if (targetVar != null && targetVar is ListVariable) {
          targetVar.value.clear();
          return '0';
        }
        return '0';

      case 'COUNT':
        if (targetVar != null && targetVar is ListVariable) {
          return targetVar.value.length.toString();
        }
        return '0';

      default:
        throw UnsupportedError('Unsupported LIST action: $action');
    }
  }

  Future<String> _executeVariableOperation(BotData data) async {
    final interpolatedTarget =
        InterpolationEngine.interpolate(targetName, data.variables, data);
    final targetVar = data.variables.get(interpolatedTarget);

    if (targetVar == null) return '';
    final stringValue = targetVar.asString();

    switch (action.toUpperCase()) {
      case 'SPLIT':
        final separator = parameters.isNotEmpty
            ? InterpolationEngine.interpolate(
                parameters[0], data.variables, data)
            : ',';
        final splitResult = stringValue.split(separator);

        final listVar =
            VariableFactory.fromObject(interpolatedTarget, splitResult);
        data.variables.set(listVar);

        return splitResult.length.toString();

      case 'JOIN':
        // If variable is a list, join it
        if (targetVar is ListVariable) {
          final separator = parameters.isNotEmpty
              ? InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)
              : ',';
          final joinResult = targetVar.value.join(separator);

          // Update the original variable to be a string
          final stringVar =
              VariableFactory.fromObject(interpolatedTarget, joinResult);
          data.variables.set(stringVar);

          return joinResult;
        }
        return stringValue;

      case 'REPLACE':
        if (parameters.length >= 2) {
          final oldValue = InterpolationEngine.interpolate(
              parameters[0], data.variables, data);
          final newValue = InterpolationEngine.interpolate(
              parameters[1], data.variables, data);
          final result = stringValue.replaceAll(oldValue, newValue);

          // Update the original variable
          final updatedVar =
              VariableFactory.fromObject(interpolatedTarget, result);
          data.variables.set(updatedVar);

          return result;
        }
        return stringValue;

      case 'SUBSTRING':
        if (parameters.length >= 2) {
          final startIndex = int.tryParse(InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)) ??
              0;
          final length = int.tryParse(InterpolationEngine.interpolate(
                  parameters[1], data.variables, data)) ??
              1;

          if (startIndex >= 0 && startIndex < stringValue.length) {
            final endIndex = (startIndex + length).clamp(0, stringValue.length);
            return stringValue.substring(startIndex, endIndex);
          }
        }
        return stringValue;

      case 'TOUPPER':
        final result = stringValue.toUpperCase();
        final updatedVar =
            VariableFactory.fromObject(interpolatedTarget, result);
        data.variables.set(updatedVar);
        return result;

      case 'TOLOWER':
        final result = stringValue.toLowerCase();
        final updatedVar =
            VariableFactory.fromObject(interpolatedTarget, result);
        data.variables.set(updatedVar);
        return result;

      case 'LENGTH':
        return stringValue.length.toString();

      default:
        throw UnsupportedError('Unsupported VARIABLE action: $action');
    }
  }

  Future<String> _executeConversionOperation(BotData data) async {
    final input = parameters.isNotEmpty
        ? InterpolationEngine.interpolate(parameters[0], data.variables, data)
        : '';

    switch (action.toUpperCase()) {
      case 'BASE64':
        final bytes = utf8.encode(input);
        return base64Encode(bytes);

      case 'FROMBASE64':
        try {
          final bytes = base64Decode(input);
          return utf8.decode(bytes);
        } catch (e) {
          return '';
        }

      case 'HEX':
        final bytes = utf8.encode(input);
        return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      case 'FROMHEX':
        try {
          final bytes = <int>[];
          for (var i = 0; i < input.length; i += 2) {
            final hexByte = input.substring(i, i + 2);
            bytes.add(int.parse(hexByte, radix: 16));
          }
          return utf8.decode(bytes);
        } catch (e) {
          return '';
        }

      case 'URL':
        return Uri.encodeComponent(input);

      case 'FROMURL':
        return Uri.decodeComponent(input);

      case 'HTML':
        return input
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#x27;');

      case 'FROMHTML':
        return input
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&#x27;', "'");

      case 'JSON':
        return jsonEncode(input);

      case 'FROMJSON':
        try {
          final decoded = jsonDecode(input);
          return decoded.toString();
        } catch (e) {
          return '';
        }

      default:
        throw UnsupportedError('Unsupported CONVERSION action: $action');
    }
  }

  Future<String> _executeFileOperation(BotData data) async {
    final interpolatedTarget =
        InterpolationEngine.interpolate(targetName, data.variables, data);

    switch (action.toUpperCase()) {
      case 'READ':
        try {
          if (await fileSystemService.exists(interpolatedTarget)) {
            return await fileSystemService.readFile(interpolatedTarget);
          }
          return '';
        } catch (e) {
          return '';
        }

      case 'WRITE':
        try {
          final content = parameters.isNotEmpty
              ? InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)
              : '';
          await fileSystemService.writeFile(interpolatedTarget, content);
          return content.length.toString();
        } catch (e) {
          return '0';
        }

      case 'APPEND':
        try {
          final content = parameters.isNotEmpty
              ? InterpolationEngine.interpolate(
                  parameters[0], data.variables, data)
              : '';
          String existingContent = '';
          if (await fileSystemService.exists(interpolatedTarget)) {
            existingContent =
                await fileSystemService.readFile(interpolatedTarget);
          }
          await fileSystemService.writeFile(
              interpolatedTarget, existingContent + content);
          return content.length.toString();
        } catch (e) {
          return '0';
        }

      case 'DELETE':
        try {
          if (await fileSystemService.exists(interpolatedTarget)) {
            await fileSystemService.deleteFile(interpolatedTarget);
            return 'true';
          }
          return 'false';
        } catch (e) {
          return 'false';
        }

      case 'EXISTS':
        return (await fileSystemService.exists(interpolatedTarget)).toString();

      default:
        throw UnsupportedError('Unsupported FILE action: $action');
    }
  }

  @override
  void fromLoliCode(String content) {
    final lines = content.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('UTILITY ')) {
        _parseOpenBulletSyntax(trimmed);
      }
    }
  }

  void _parseOpenBulletSyntax(String line) {
    // Parse: UTILITY LIST "ListName" ACTION [PARAMETERS] [-> VAR/CAP "NAME"]
    // Parse: UTILITY VARIABLE "VarName" ACTION [PARAMETERS] [-> VAR/CAP "NAME"]
    // Parse: UTILITY CONVERSION FROM TO "input" [-> VAR/CAP "NAME"]
    // Parse: UTILITY FILE "FileName" ACTION [PARAMETERS] [-> VAR/CAP "NAME"]

    var remaining = line.substring(7).trim(); // Remove "UTILITY"

    // Extract operation type
    final typeMatch = RegExp(r'^(\w+)').firstMatch(remaining);
    if (typeMatch != null) {
      final typeStr = typeMatch.group(1)!.toUpperCase();
      remaining = remaining.substring(typeMatch.end).trim();

      switch (typeStr) {
        case 'LIST':
          operationType = UtilityOperationType.LIST;
          _parseListSyntax(remaining);
          break;
        case 'VARIABLE':
          operationType = UtilityOperationType.VARIABLE;
          _parseVariableSyntax(remaining);
          break;
        case 'CONVERSION':
          operationType = UtilityOperationType.CONVERSION;
          _parseConversionSyntax(remaining);
          break;
        case 'FILE':
          operationType = UtilityOperationType.FILE;
          _parseFileSyntax(remaining);
          break;
      }
    }
  }

  void _parseListSyntax(String remaining) {
    // Parse: "ListName" ACTION [PARAMETERS] [-> VAR/CAP "NAME"]

    // Extract target name
    final nameMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
    if (nameMatch != null) {
      targetName = nameMatch.group(1)!;
      remaining = remaining.substring(nameMatch.end).trim();
    }

    // Extract action
    final actionMatch = RegExp(r'^(\w+)').firstMatch(remaining);
    if (actionMatch != null) {
      action = actionMatch.group(1)!;
      remaining = remaining.substring(actionMatch.end).trim();
    }

    _parseParametersAndOutput(remaining);
  }

  void _parseVariableSyntax(String remaining) {
    // Parse: "VarName" ACTION [PARAMETERS] [-> VAR/CAP "NAME"]

    // Extract target name
    final nameMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
    if (nameMatch != null) {
      targetName = nameMatch.group(1)!;
      remaining = remaining.substring(nameMatch.end).trim();
    }

    // Extract action
    final actionMatch = RegExp(r'^(\w+)').firstMatch(remaining);
    if (actionMatch != null) {
      action = actionMatch.group(1)!;
      remaining = remaining.substring(actionMatch.end).trim();
    }

    _parseParametersAndOutput(remaining);
  }

  void _parseConversionSyntax(String remaining) {
    // Parse: FROM TO "input" [-> VAR/CAP "NAME"]

    // Extract FROM type
    final fromMatch = RegExp(r'^(\w+)').firstMatch(remaining);
    if (fromMatch != null) {
      final fromType = fromMatch.group(1)!;
      remaining = remaining.substring(fromMatch.end).trim();

      // Extract TO type
      final toMatch = RegExp(r'^(\w+)').firstMatch(remaining);
      if (toMatch != null) {
        final toType = toMatch.group(1)!;
        remaining = remaining.substring(toMatch.end).trim();

        // Determine action based on conversion types
        if (fromType.toUpperCase() == 'BASE64' &&
            toType.toUpperCase() == 'HEX') {
          action = 'BASE64';
        } else if (fromType.toUpperCase() == 'HEX' &&
            toType.toUpperCase() == 'BASE64') {
          action = 'HEX';
        } else {
          action = fromType.toUpperCase();
        }
      }
    }

    _parseParametersAndOutput(remaining);
  }

  void _parseFileSyntax(String remaining) {
    // Parse: "FileName" ACTION [PARAMETERS] [-> VAR/CAP "NAME"]

    // Extract target name
    final nameMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
    if (nameMatch != null) {
      targetName = nameMatch.group(1)!;
      remaining = remaining.substring(nameMatch.end).trim();
    }

    // Extract action
    final actionMatch = RegExp(r'^(\w+)').firstMatch(remaining);
    if (actionMatch != null) {
      action = actionMatch.group(1)!;
      remaining = remaining.substring(actionMatch.end).trim();
    }

    _parseParametersAndOutput(remaining);
  }

  void _parseParametersAndOutput(String remaining) {
    // Extract parameters

    parameters.clear();

    // Extract all quoted parameters
    while (remaining.isNotEmpty) {
      final paramMatch = RegExp(r'^"([^"]*)"').firstMatch(remaining);
      if (paramMatch != null) {
        if (remaining.substring(paramMatch.start).startsWith('-> ')) {
          break;
        }
        parameters.add(paramMatch.group(1)!);
        remaining = remaining.substring(paramMatch.end).trim();
      } else {
        break;
      }
    }

    // Parse output directive: -> VAR/CAP "name"
    final outputMatch =
        RegExp(r'->\s*(VAR|CAP)\s+"([^"]*)"', caseSensitive: false)
            .firstMatch(remaining);
    if (outputMatch != null) {
      outputType = outputMatch.group(1)!.toUpperCase();
      outputVariable = outputMatch.group(2)!;
    }
  }

  @override
  String toLoliCode() {
    final buffer = StringBuffer();

    buffer.write(
        'UTILITY ${operationType.toString().split('.').last.toUpperCase()}');

    switch (operationType) {
      case UtilityOperationType.LIST:
      case UtilityOperationType.VARIABLE:
      case UtilityOperationType.FILE:
        buffer.write(' "$targetName" $action');
        break;
      case UtilityOperationType.CONVERSION:
        buffer.write(' BASE64 HEX');
        break;
    }

    for (final param in parameters) {
      buffer.write(' "$param"');
    }

    if (outputVariable.isNotEmpty) {
      buffer.write(' -> $outputType "$outputVariable"');
    }

    buffer.writeln();
    return buffer.toString();
  }
}
