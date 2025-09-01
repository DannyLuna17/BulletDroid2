import '../base/block_instance.dart';
import '../../core/bot_data.dart';
import '../../parsing/interpolation_engine.dart';
import '../../variables/variable_factory.dart';

class FunctionBlock extends BlockInstance {
  String functionName = '';
  String outputVariable = '';
  List<String> parameters = [];

  FunctionBlock() : super(id: 'Function');

  @override
  Future<void> execute(BotData data) async {
    try {
      String result = '';

      switch (functionName.toLowerCase()) {
        case 'getrandomua':
          result = _getRandomUserAgent();
          break;
        case 'constant':
          result = parameters.isNotEmpty ? parameters[0] : '';
          break;
        case 'timestamp':
          result = DateTime.now().millisecondsSinceEpoch.toString();
          break;
        case 'random':
          if (parameters.length >= 2) {
            final min = int.tryParse(parameters[0]) ?? 0;
            final max = int.tryParse(parameters[1]) ?? 100;
            result = (min +
                    (max - min) *
                        (DateTime.now().millisecondsSinceEpoch % 1000) /
                        1000)
                .round()
                .toString();
          }
          break;
        case 'base64encode':
          if (parameters.isNotEmpty) {
            result = _base64Encode(parameters[0]);
          }
          break;
        case 'base64decode':
          if (parameters.isNotEmpty) {
            result = _base64Decode(parameters[0]);
          }
          break;
        default:
          data.logWarning('Unknown function: $functionName');
          result = '';
      }

      // Interpolate the result
      result = InterpolationEngine.interpolate(result, data.variables, data);

      // Set the output variable
      if (outputVariable.isNotEmpty) {
        final variable = VariableFactory.fromObject(outputVariable, result);
        data.variables.set(variable);
        data.log('Function $functionName -> $outputVariable = "$result"');
      }
    } catch (e, stackTrace) {
      data.logError('Function execution failed: $e');
      data.logError('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  void fromLoliCode(String content) {
    // Parse: FUNCTION FunctionName "param1" "param2" -> VAR "outputVar"
    final parts = content.trim().split(' ');
    if (parts.length < 2) return;

    functionName = parts[1];

    // Find the arrow and output variable
    final arrowIndex = content.indexOf('->');
    if (arrowIndex != -1) {
      final afterArrow = content.substring(arrowIndex + 2).trim();
      if (afterArrow.startsWith('VAR ')) {
        outputVariable = afterArrow.substring(4).replaceAll('"', '').trim();
      }

      // Extract parameters before the arrow
      final beforeArrow = content.substring(0, arrowIndex).trim();
      final paramStart =
          beforeArrow.indexOf(functionName) + functionName.length;
      final paramString = beforeArrow.substring(paramStart).trim();

      if (paramString.isNotEmpty) {
        // Parse quoted parameters
        final regex = RegExp(r'"([^"]*)"');
        final matches = regex.allMatches(paramString);
        parameters = matches.map((match) => match.group(1)!).toList();
      }
    }
  }

  @override
  String toLoliCode() {
    final buffer = StringBuffer();
    buffer.write('FUNCTION $functionName');

    for (final param in parameters) {
      buffer.write(' "$param"');
    }

    if (outputVariable.isNotEmpty) {
      buffer.write(' -> VAR "$outputVariable"');
    }

    return buffer.toString();
  }

  String _getRandomUserAgent() {
    final userAgents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    ];

    final index = DateTime.now().millisecondsSinceEpoch % userAgents.length;
    return userAgents[index];
  }

  String _base64Encode(String input) {
    try {
      return Uri.encodeComponent(input);
    } catch (e) {
      return input;
    }
  }

  String _base64Decode(String input) {
    try {
      return Uri.decodeComponent(input);
    } catch (e) {
      return input;
    }
  }
}
