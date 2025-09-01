import 'bot_data.dart';
import 'config.dart';
import 'status.dart';
import 'app_configuration.dart';
import 'custom_input_handler.dart';
import '../variables/variable_pool.dart';

class ExecutionEngine {
  static Future<BotData> execute(Config config, BotData data,
      {Duration? timeout}) async {
    timeout ??= Duration(milliseconds: AppConfiguration.defaultTimeout);

    try {
      data.log('Starting config execution: ${config.metadata.name}');

      data.configSettings = config.settings;

      await CustomInputHandler.processCustomInputs(
          config.settings, data.variables);

      CustomInputHandler.setDefaultCustomInputs(
          config.settings, data.variables);

      // Execute with timeout
      return await _executeBlocks(config, data).timeout(
        timeout,
        onTimeout: () {
          data.logError(
              'Execution timed out after ${timeout!.inSeconds} seconds');
          data.status = BotStatus.ERROR;
          return data;
        },
      );
    } catch (e, stackTrace) {
      data.logError('Execution engine error: $e');
      data.logError('Stack trace: $stackTrace');
      data.status = BotStatus.ERROR;
      return data;
    }
  }

  static Future<BotData> _executeBlocks(Config config, BotData data) async {
    for (var i = 0; i < config.blocks.length; i++) {
      final block = config.blocks[i];

      if (block.disabled) {
        data.log('Skipping disabled block: ${block.id}');
        continue;
      }

      data.log('Executing block ${i + 1}/${config.blocks.length}: ${block.id}');

      try {
        // Execute the block with individual timeout
        await block.execute(data).timeout(
          Duration(milliseconds: AppConfiguration.blockTimeout),
          onTimeout: () {
            final configured =
                Duration(milliseconds: AppConfiguration.blockTimeout);
            data.logError(
                'Block ${block.id} timed out after ${configured.inSeconds} seconds');
            throw TimeoutException('Block execution timeout', configured);
          },
        );

        if (_shouldStopExecution(data.status)) {
          data.log('Stopping execution due to status: ${data.status}');
          break;
        }
      } catch (e, stackTrace) {
        data.logError('Block execution failed: $e');
        data.logError('Block: ${block.id}');
        data.logError('Stack trace: $stackTrace');

        if (block.safe) {
          data.logWarning('Safe block failed, continuing execution');
          continue;
        } else {
          data.status = BotStatus.ERROR;
          data.logError('Non-safe block failed, stopping execution');
          break;
        }
      }
    }

    if (data.status == BotStatus.NONE) {
      data.status = BotStatus.TOCHECK;
      data.log('Final status: TOCHECK (converted from NONE)');
    }

    data.log('Config execution completed with status: ${data.status}');

    return data;
  }

  static bool _shouldStopExecution(BotStatus status) {
    switch (status) {
      case BotStatus.ERROR:
        // Only stop execution on ERROR status
        return true;
      case BotStatus.SUCCESS:
      case BotStatus.FAIL:
      case BotStatus.BAN:
      case BotStatus.UNKNOWN:
      case BotStatus.CUSTOM:
      case BotStatus.RETRY:
      case BotStatus.NONE:
      case BotStatus.TOCHECK:
        // Continue execution - subsequent blocks might change the status
        return false;
    }
  }

  static Future<List<BotData>> executeMultiple(
      Config config, List<String> inputs,
      {int? maxConcurrency, Duration? timeout}) async {
    maxConcurrency ??= AppConfiguration.maxConcurrency;
    timeout ??= Duration(minutes: 5);

    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print(
          '[INFO] Starting batch execution of ${inputs.length} inputs with max concurrency: $maxConcurrency');
    }

    // Collect custom inputs once for all executions
    final sharedVariables = VariablePool();
    await CustomInputHandler.processCustomInputs(
        config.settings, sharedVariables);
    CustomInputHandler.setDefaultCustomInputs(config.settings, sharedVariables);

    final results = <BotData>[];
    final futures = <Future<BotData>>[];

    for (var i = 0; i < inputs.length; i++) {
      final data = BotData(input: inputs[i]);

      // Copy custom input variables to this execution's variable pool
      for (final customInput in config.settings.customInputs) {
        if (sharedVariables.exists(customInput.variableName)) {
          final value = sharedVariables.get(customInput.variableName)!;
          data.variables.set(value);
        }
      }

      // Execute without prompting for custom inputs again
      final future =
          _executeBatch(config, data, timeout: Duration(seconds: 30));
      futures.add(future);

      // Limit concurrency
      if (futures.length >= maxConcurrency || i == inputs.length - 1) {
        if (AppConfiguration.debugMode) {
          // ignore: avoid_print
          print('[INFO] Executing batch of ${futures.length} configs...');
        }
        final batchResults = await Future.wait(futures);
        results.addAll(batchResults);
        futures.clear();

        // Progress update
        if (AppConfiguration.debugMode) {
          // ignore: avoid_print
          print(
              '[INFO] Completed ${results.length}/${inputs.length} executions');
        }
      }
    }

    if (AppConfiguration.debugMode) {
      // ignore: avoid_print
      print('[INFO] Batch execution completed');
    }
    return results;
  }

  /// Execute a config without processing custom inputs (for batch execution)
  static Future<BotData> _executeBatch(Config config, BotData data,
      {Duration? timeout}) async {
    timeout ??= Duration(milliseconds: AppConfiguration.defaultTimeout);

    try {
      data.log('Starting config execution: ${config.metadata.name}');

      data.configSettings = config.settings;

      return await _executeBlocks(config, data).timeout(
        timeout,
        onTimeout: () {
          data.logError(
              'Execution timed out after ${timeout!.inSeconds} seconds');
          data.status = BotStatus.ERROR;
          return data;
        },
      );
    } catch (e, stackTrace) {
      data.logError('Execution engine error: $e');
      data.logError('Stack trace: $stackTrace');
      data.status = BotStatus.ERROR;
      return data;
    }
  }

  static Map<String, int> getStatusCounts(List<BotData> results) {
    final counts = <String, int>{};

    for (final result in results) {
      final statusName = result.status.toString().split('.').last;
      counts[statusName] = (counts[statusName] ?? 0) + 1;
    }

    return counts;
  }

  static List<BotData> getSuccessfulResults(List<BotData> results) {
    return results.where((r) => r.status == BotStatus.SUCCESS).toList();
  }

  static List<BotData> getFailedResults(List<BotData> results) {
    return results.where((r) => r.status == BotStatus.FAIL).toList();
  }

  static double getSuccessRate(List<BotData> results) {
    if (results.isEmpty) return 0.0;
    final successCount =
        results.where((r) => r.status == BotStatus.SUCCESS).length;
    return successCount / results.length;
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (${timeout.inSeconds}s)';
}
