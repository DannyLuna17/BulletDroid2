// LunaLib - Mobile LoliCode Config Runner

import 'core/bot_data.dart';
import 'core/config.dart';
import 'core/execution_engine.dart';
import 'core/app_configuration.dart';
import 'services/file_system_service.dart';
import 'parsing/loli_parser.dart';
import 'blocks/base/block_factory.dart';

export 'core/bot_data.dart';
export 'core/config.dart';
export 'core/config_settings.dart';
export 'core/execution_engine.dart';
export 'core/status.dart';
export 'core/app_configuration.dart';
export 'core/custom_input_handler.dart';
export 'services/file_system_service.dart';

export 'variables/variable.dart';
export 'variables/variable_types.dart';
export 'variables/variable_factory.dart';
export 'variables/variable_pool.dart';

export 'parsing/loli_parser.dart';
export 'parsing/line_parser.dart';
export 'parsing/interpolation_engine.dart';

export 'blocks/base/block_instance.dart';
export 'blocks/base/block_descriptor.dart';
export 'blocks/base/block_factory.dart';

export 'blocks/http/request_block.dart';
export 'blocks/parsing/parse_block.dart';
export 'blocks/logic/keycheck_block.dart';
export 'blocks/logic/function_block.dart';
export 'blocks/utility/loli_code_block.dart';

export 'utils/config_loader.dart';

/// Main LunaLib class
class LunaLib {
  /// Initialize LunaLib with optional configuration
  static Future<void> initialize({
    AppConfiguration? configuration,
    FileSystemService? fileService,
  }) async {
    // Set file system service if provided
    if (fileService != null) {
      fileSystemService = fileService;
    }

    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print('[LunaLib] Initialized with configuration');
    }
  }

  /// Parse a .loli config file content into a Config object
  static Config parseConfig(String loliCode) {
    return LoliParser.parseConfig(loliCode);
  }

  /// Execute a config with input data
  static Future<BotData> executeConfig(Config config, String input) async {
    final data = BotData(input: input);
    return ExecutionEngine.execute(config, data);
  }

  /// Execute a config with multiple inputs concurrently
  static Future<List<BotData>> executeConfigMultiple(
      Config config, List<String> inputs,
      {int? maxConcurrency}) async {
    return ExecutionEngine.executeMultiple(config, inputs,
        maxConcurrency: maxConcurrency ?? AppConfiguration.maxConcurrency);
  }

  /// Parse and execute a .loli config in one step
  static Future<BotData> runLoliCode(String loliCode, String input) async {
    final config = parseConfig(loliCode);
    return executeConfig(config, input);
  }

  /// Parse and execute a .loli config with multiple inputs
  static Future<List<BotData>> runLoliCodeMultiple(
      String loliCode, List<String> inputs,
      {int? maxConcurrency}) async {
    final config = parseConfig(loliCode);
    return executeConfigMultiple(config, inputs,
        maxConcurrency: maxConcurrency);
  }

  /// Validate if a string is valid LoliCode
  static bool isValidLoliCode(String loliCode) {
    return LoliParser.isValidLoliCode(loliCode);
  }

  /// Get supported block types
  static List<String> getSupportedBlocks() {
    return BlockFactory.getSupportedBlockTypes();
  }

  /// Convert a Config back to LoliCode
  static String configToLoliCode(Config config) {
    return LoliParser.configToLoliCode(config);
  }

  /// Get execution statistics from results
  static Map<String, dynamic> getExecutionStats(List<BotData> results) {
    return {
      'total': results.length,
      'statusCounts': ExecutionEngine.getStatusCounts(results),
      'successRate': ExecutionEngine.getSuccessRate(results),
      'successful': ExecutionEngine.getSuccessfulResults(results).length,
      'failed': ExecutionEngine.getFailedResults(results).length,
    };
  }
}
