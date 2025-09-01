import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid/shared/utils/wordlist_utils.dart';
import 'package:hive/hive.dart';
import 'dart:io';

import 'package:bullet_droid/features/dashboard/models/config_execution.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/runner/providers/runner_provider.dart';
import 'package:bullet_droid/features/dashboard/services/execution_sync_service.dart';
import 'package:bullet_droid/features/runner/models/runner_instance.dart';
import 'package:bullet_droid/features/runner/models/job_params.dart';
import 'package:bullet_droid/features/wordlists/providers/wordlists_provider.dart';
import 'package:bullet_droid/shared/providers/custom_input_provider.dart';
import 'package:bullet_droid/shared/providers/hive_provider.dart';
import 'package:bullet_droid/core/utils/logging.dart';
import 'package:bullet_droid/features/proxies/providers/proxies_provider.dart';

// Provider for managing config executions on dashboard
final configExecutionsProvider =
    StateNotifierProvider<ConfigExecutionsNotifier, List<ConfigExecution>>((
      ref,
    ) {
      final dashboardBox = ref.watch(dashboardExecutionsBoxProvider);
      return ConfigExecutionsNotifier(ref, dashboardBox);
    });

class ConfigExecutionsNotifier extends StateNotifier<List<ConfigExecution>> {
  final Ref _ref;
  final Box _dashboardBox;

  late final ExecutionSyncService _sync;

  ConfigExecutionsNotifier(this._ref, this._dashboardBox) : super([]) {
    _sync = ExecutionSyncService(
      ref: _ref,
      getState: () => state,
      setState: (s) => state = s,
      persistExecution: _persistExecution,
      deleteExecution: _deleteExecution,
      handleRunnerError: _handleRunnerError,
    );
    _loadPersistedExecutions();
    Future.microtask(() => _sync.initialize());
  }

  void _loadPersistedExecutions() {
    try {
      final executions = <ConfigExecution>[];

      for (final key in _dashboardBox.keys) {
        final data = _dashboardBox.get(key);
        if (data != null) {
          try {
            final execution = ConfigExecution.fromJson(
              Map<String, dynamic>.from(data),
            );
            executions.add(execution);

            if (execution.runnerId != null && !execution.isPlaceholder) {
              _sync.executionToRunnerIdMap[execution.id] = execution.runnerId!;
            } else if (!execution.isPlaceholder) {
              // Execution exists but has no runner ID, this needs fixing
            }
          } catch (e) {
            // Skip invalid entries
          }
        }
      }

      // Sort by creation time (newest first)
      executions.sort(
        (a, b) => (b.startTime ?? DateTime.now()).compareTo(
          a.startTime ?? DateTime.now(),
        ),
      );

      state = executions;
      // Fix mappings and uniqueness
      _sync.ensureAllExecutionsHaveRunners();
      _sync.ensureUniqueRunnersPerExecution();
    } catch (e) {
      state = [];
    }
  }

  Future<void> _persistExecution(ConfigExecution execution) async {
    try {
      await _dashboardBox.put(execution.id, execution.toJson());
    } catch (e) {
      Log.w('Error persisting execution ${execution.id}: $e');
    }
  }

  Future<void> _deleteExecution(String executionId) async {
    try {
      await _dashboardBox.delete(executionId);
    } catch (e) {
      Log.w('Error deleting execution $executionId: $e');
    }
  }

  // Runner creation method (per execution)
  Future<String> _createRunnerInstanceForExecution(
    String executionId,
    String configId,
  ) async {
    final runnerId =
        'dashboard_${configId}_${DateTime.now().millisecondsSinceEpoch}';

    // Initialize runner with proper context and config ID
    await _ref
        .read(multiRunnerProvider.notifier)
        .initializeWithContextForRunner(
          runnerId,
          RunnerContext.configExisting,
          configId,
        );

    // Store mapping to this execution
    _sync.executionToRunnerIdMap[executionId] = runnerId;

    // Persist runnerId on execution state
    state = state.map((exec) {
      if (exec.id == executionId) {
        final updated = exec.copyWith(runnerId: runnerId);
        _persistExecution(updated);
        return updated;
      }
      return exec;
    }).toList();

    return runnerId;
  }

  // Validation method per execution
  Future<String?> _validateExecutionForStart(
    String executionId, {
    bool skipRunnerCreation = false,
  }) async {
    try {
      final execution = state.firstWhere((e) => e.id == executionId);
      final configId = execution.configId;
      String? runnerId =
          _sync.executionToRunnerIdMap[executionId] ?? execution.runnerId;

      if (runnerId == null) {
        if (skipRunnerCreation) {
          return 'Runner not initialized';
        }

        // Create runner if missing
        runnerId = await _createRunnerInstanceForExecution(
          executionId,
          configId,
        );
      }

      // Wait briefly for runner instance recovery after cold start
      {
        int attempts = 0;
        const int maxAttempts = 50;
        while (attempts < maxAttempts) {
          final instance = _ref.read(runnerInstanceProvider(runnerId));
          if (instance != null) break;
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      }
      var runnerInstance = _ref.read(runnerInstanceProvider(runnerId));
      if (runnerInstance == null) {
        // Attempt to initialize missing runner (cold restart)
        await _ref
            .read(multiRunnerProvider.notifier)
            .initializeWithContextForRunner(
              runnerId,
              RunnerContext.configExisting,
              configId,
            );
        int attempts = 0;
        const int maxAttempts = 30; // ~3s
        while (attempts < maxAttempts) {
          runnerInstance = _ref.read(runnerInstanceProvider(runnerId));
          if (runnerInstance != null) break;
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
        if (runnerInstance == null) {
          return 'Runner instance not found';
        }
      }

      // Ensure the runner's selected config matches this execution's config
      if (runnerInstance.selectedConfigId != configId) {
        await _ref
            .read(multiRunnerProvider.notifier)
            .updateSelectedConfigForRunner(runnerId, configId);
      }
      var updatedRunner = _ref.read(runnerInstanceProvider(runnerId));
      // Wait for configs/wordlists to be ready after app restart
      {
        int attempts = 0;
        const int maxAttempts = 50;
        while (attempts < maxAttempts) {
          final configsState = _ref.read(configsProvider);
          final wordlistsState = _ref.read(wordlistsProvider);
          if (!configsState.isLoading && !wordlistsState.isLoading) break;
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      }
      updatedRunner = _ref.read(runnerInstanceProvider(runnerId));
      // Apply execution-stored params if missing on runner after restart
      final execState = state.firstWhere((e) => e.id == executionId);
      if (updatedRunner?.selectedWordlistId == null &&
          execState.selectedWordlistId != null) {
        await _ref
            .read(multiRunnerProvider.notifier)
            .updateSelectedWordlistForRunner(
              runnerId,
              execState.selectedWordlistId,
            );
        updatedRunner = _ref.read(runnerInstanceProvider(runnerId));
      }
      if ((updatedRunner?.botsCount ?? 0) <= 0 && execState.totalBots > 0) {
        await _ref
            .read(multiRunnerProvider.notifier)
            .updateBotsCountForRunner(runnerId, execState.totalBots);
        updatedRunner = _ref.read(runnerInstanceProvider(runnerId));
      }

      // Check if runner has active job
      if (updatedRunner?.hasActiveJob == true) {
        return 'Runner is already running';
      }

      // Check config selection
      if (updatedRunner?.selectedConfigId == null) {
        return 'Please configure runner first. Go to Runner screen to set up configuration.';
      }

      // Check wordlist selection
      if (updatedRunner?.selectedWordlistId == null) {
        return 'Please configure runner first. Go to Runner screen to set up wordlist.';
      }

      // Check bot count
      if ((updatedRunner?.botsCount ?? 0) <= 0) {
        return 'Please configure runner first. Go to Runner screen to set up bot count.';
      }

      // Check if config file exists
      final configs = _ref.read(configsProvider).configs;
      final config = configs
          .where((c) => c.id == updatedRunner?.selectedConfigId)
          .firstOrNull;
      if (config == null) {
        return 'Config not found';
      }

      if (!File(config.filePath).existsSync()) {
        return 'Config file does not exist: ${config.filePath}';
      }

      // Check if wordlist exists
      final wordlists = _ref.read(wordlistsProvider).wordlists;
      final wordlist = wordlists
          .where((w) => w.id == updatedRunner?.selectedWordlistId)
          .firstOrNull;
      if (wordlist == null) {
        return 'Wordlist not found';
      }

      if (!File(wordlist.path).existsSync()) {
        return 'Wordlist file does not exist: ${wordlist.path}';
      }

      return null; // Valid
    } catch (e) {
      return 'Validation error: ${e.toString()}';
    }
  }

  // Error handling method
  void _handleRunnerError(String executionId, String error) {
    final updatedState = state.map((exec) {
      if (exec.id == executionId) {
        return exec.copyWith(
          isRunning: false,
          validationError: error,
          endTime: DateTime.now(),
        );
      }
      return exec;
    }).toList();

    state = updatedState;

    // Persist error state
    final execution = updatedState.firstWhere((exec) => exec.id == executionId);
    _persistExecution(execution);
  }

  // Refresh configuration status for a specific execution
  Future<void> refreshExecutionStatus(String executionId) async {
    final exec = state.firstWhere((e) => e.id == executionId);
    // Ensure we have a runner for this execution
    String? runnerId =
        _sync.executionToRunnerIdMap[executionId] ?? exec.runnerId;
    runnerId ??= await _createRunnerInstanceForExecution(
      executionId,
      exec.configId,
    );

    final validationError = await _validateExecutionForStart(
      executionId,
      skipRunnerCreation: true,
    );
    final isConfigured = validationError == null;

    final updatedState = state.map((e) {
      if (e.id == executionId) {
        final updated = e.copyWith(
          runnerId: runnerId,
          isConfigured: isConfigured,
          validationError: isConfigured ? null : validationError,
        );
        _persistExecution(updated);
        return updated;
      }
      return e;
    }).toList();

    state = updatedState;
  }

  Future<void> startExecution(String executionId) async {
    try {
      final exec = state.firstWhere((e) => e.id == executionId);
      // Get or create runner instance for this execution
      String? runnerId =
          _sync.executionToRunnerIdMap[executionId] ?? exec.runnerId;
      if (runnerId == null) {
        runnerId = await _createRunnerInstanceForExecution(
          executionId,
          exec.configId,
        );
      } else {}

      // Ensure no other execution shares this runner
      final conflict = state.any(
        (e) =>
            !e.isPlaceholder &&
            e.id != executionId &&
            (_sync.executionToRunnerIdMap[e.id] ?? e.runnerId) == runnerId,
      );
      if (conflict) {
        final newRunnerId = await _createRunnerInstanceForExecution(
          executionId,
          exec.configId,
        );
        // Initialize from execution-specific parameters
        await _ref
            .read(multiRunnerProvider.notifier)
            .updateSelectedConfigForRunner(newRunnerId, exec.configId);
        if (exec.selectedWordlistId != null) {
          await _ref
              .read(multiRunnerProvider.notifier)
              .updateSelectedWordlistForRunner(
                newRunnerId,
                exec.selectedWordlistId,
              );
        }
        if (exec.totalBots > 0) {
          await _ref
              .read(multiRunnerProvider.notifier)
              .updateBotsCountForRunner(newRunnerId, exec.totalBots);
        }
        runnerId = newRunnerId;
        _sync.executionToRunnerIdMap[executionId] = newRunnerId;
        // Persist execution runnerId change
        state = state.map((e) {
          if (e.id == executionId) {
            final updated = e.copyWith(runnerId: newRunnerId);
            _persistExecution(updated);
            return updated;
          }
          return e;
        }).toList();
      }

      if (exec.selectedWordlistId != null) {
        await _ref
            .read(multiRunnerProvider.notifier)
            .updateSelectedWordlistForRunner(runnerId, exec.selectedWordlistId);
      }

      // Validate configuration
      final validationError = await _validateExecutionForStart(
        executionId,
        skipRunnerCreation: true,
      );
      if (validationError != null) {
        _handleRunnerError(executionId, validationError);
        return;
      }

      // Get runner instance and required data
      final runnerInstance = _ref.read(runnerInstanceProvider(runnerId));
      if (runnerInstance == null) {
        _handleRunnerError(executionId, 'Runner instance not found');
        return;
      }

      final configs = _ref.read(configsProvider).configs;
      final config = configs.firstWhere(
        (c) => c.id == runnerInstance.selectedConfigId,
      );

      final wordlists = _ref.read(wordlistsProvider).wordlists;
      final wordlist = wordlists.firstWhere(
        (w) => w.id == runnerInstance.selectedWordlistId,
      );

      // Read and process wordlist content
      final wordlistFile = File(wordlist.path);
      final dataLines = await WordlistUtils.readAndProcessFile(wordlistFile);

      if (dataLines.isEmpty) {
        _handleRunnerError(
          executionId,
          'No valid data lines found in wordlist',
        );
        return;
      }

      // Get custom input values
      final customInputValues = await _ref
          .read(customInputProvider.notifier)
          .getCustomInputsForJob(config.id);

      // Build proxy list if proxies are enabled
      List<String> proxyStrings = [];
      if (runnerInstance.useProxies) {
        final proxiesState = _ref.read(proxiesProvider);
        final eligibleProxies = [
          ...proxiesState.aliveProxies,
          ...proxiesState.untestedProxies,
        ];

        if (eligibleProxies.isEmpty) {
          _handleRunnerError(
            executionId,
            'No eligible proxies (alive/untested) available',
          );
          return;
        }

        proxyStrings = eligibleProxies.map((p) {
          final hasUser = (p.username != null && p.username!.isNotEmpty);
          final hasPass = (p.password != null && p.password!.isNotEmpty);
          if (hasUser && hasPass) {
            return '${p.address}:${p.port}:${p.username}:${p.password}';
          }
          return '${p.address}:${p.port}';
        }).toList();
      }

      // Create job parameters
      final jobParams = JobParams(
        configId: config.id,
        configPath: config.filePath,
        dataLines: dataLines,
        threads: runnerInstance.botsCount,
        startIndex: runnerInstance.startCount - 1,
        useProxies: runnerInstance.useProxies,
        proxies: runnerInstance.useProxies ? proxyStrings : [],
        customInputs: customInputValues,
      );

      // Update UI state to running
      state = state.map((exec) {
        if (exec.id == executionId) {
          final updated = exec.copyWith(
            isRunning: true,
            processedBots: 0,
            processedData: 0,
            cpm: 0,
            good: 0,
            custom: 0,
            bad: 0,
            toCheck: 0,
            startTime: DateTime.now(),
            endTime: null,
            validationError: null,
            totalData: dataLines.length,
            runnerId: runnerId,
            isConfigured: true,
          );
          _persistExecution(updated);
          return updated;
        }
        return exec;
      }).toList();

      // Start progress subscription via sync service
      _sync.subscribeToRunnerProgress(executionId, runnerId);

      // Start the actual job
      await _ref
          .read(multiRunnerProvider.notifier)
          .startJobForRunner(runnerId, jobParams);
    } catch (e) {
      _handleRunnerError(executionId, 'Failed to start job: ${e.toString()}');
    }
  }

  Future<void> stopExecution(String executionId) async {
    try {
      final exec = state.firstWhere((e) => e.id == executionId);
      final runnerId =
          _sync.executionToRunnerIdMap[executionId] ?? exec.runnerId;
      if (runnerId == null) {
        _handleRunnerError(executionId, 'Runner not found');
        return;
      }

      // Stop the runner job
      await _ref.read(multiRunnerProvider.notifier).stopJobForRunner(runnerId);

      // Update UI state
      state = state.map((exec) {
        if (exec.id == executionId) {
          final updated = exec.copyWith(
            isRunning: false,
            endTime: DateTime.now(),
            validationError: null,
          );
          _persistExecution(updated);
          return updated;
        }
        return exec;
      }).toList();

      // Cancel progress subscription via sync service
      _sync.cancelProgressSubscriptionForExecution(executionId);
    } catch (e) {
      _handleRunnerError(executionId, 'Failed to stop job: ${e.toString()}');
    }
  }

  Future<void> deleteExecution(String executionId) async {
    // Stop runner if running
    final exec = state.firstWhere((e) => e.id == executionId);
    final runnerId = _sync.executionToRunnerIdMap[executionId] ?? exec.runnerId;
    if (runnerId != null) {
      try {
        await _ref
            .read(multiRunnerProvider.notifier)
            .stopJobForRunner(runnerId);
      } catch (e) {}
    }

    // Cancel progress subscription
    _sync.cancelProgressSubscriptionForExecution(executionId);

    // Remove runner mapping
    _sync.executionToRunnerIdMap.remove(executionId);

    // Delete only this execution
    await _deleteExecution(executionId);
    state = state.where((e) => e.id != executionId).toList();
  }

  Future<void> removePlaceholder(String placeholderId) async {
    await _deleteExecution(placeholderId);
    state = state.where((exec) => exec.id != placeholderId).toList();
  }

  Future<void> startAll() async {
    // Start all non-placeholder executions concurrently
    final executions = state.where((e) => !e.isPlaceholder).toList();
    // Ensure unique runner per execution to avoid conflicts
    await _sync.ensureUniqueRunnersPerExecution();
    // Signal UI via toast through DashboardScreen that runners are initializing
    await Future.wait(executions.map((e) => startExecution(e.id)));
  }

  Future<void> stopAll() async {
    // Stop all non-placeholder executions via provider logic
    for (final exec in state.where((e) => !e.isPlaceholder)) {
      await stopExecution(exec.id);
    }
  }

  Future<void> deleteAll() async {
    // Stop all runners and cleanup
    for (final executionId in _sync.executionToRunnerIdMap.keys.toList()) {
      final runnerId = _sync.executionToRunnerIdMap[executionId];
      if (runnerId != null) {
        try {
          await _ref
              .read(multiRunnerProvider.notifier)
              .stopJobForRunner(runnerId);
        } catch (e) {
          Log.w('Error stopping runner $runnerId during deleteAll: $e');
        }
      }
      _sync.cancelProgressSubscriptionForExecution(executionId);
    }

    // Clear mappings
    _sync.executionToRunnerIdMap.clear();

    // Delete all executions from Hive
    for (final exec in state) {
      await _deleteExecution(exec.id);
    }
    state = [];
  }

  @override
  void dispose() {
    _sync.dispose();
    super.dispose();
  }

  Future<void> addConfig(String configId) async {
    final configs = _ref.read(configsProvider).configs;
    final config = configs.firstWhere((c) => c.id == configId);

    final executionId =
        'exec_${config.id}_${DateTime.now().millisecondsSinceEpoch}';

    // Create new execution entry first (without runnerId yet)
    var newExecution = ConfigExecution(
      id: executionId,
      configId: config.id,
      configName: config.name,
      totalBots: 1,
      processedBots: 0,
      totalData: 0,
      processedData: 0,
      cpm: 0,
      good: 0,
      custom: 0,
      bad: 0,
      toCheck: 0,
      isRunning: false,
      startTime: null,
      endTime: null,
      runnerId: null,
      isConfigured: false,
      validationError: null,
    );
    await _persistExecution(newExecution);
    state = [...state, newExecution];

    // Create runner instance for this execution and validate
    final runnerId = await _createRunnerInstanceForExecution(
      executionId,
      config.id,
    );
    final validationError = await _validateExecutionForStart(
      executionId,
      skipRunnerCreation: true,
    );
    final isConfigured = validationError == null;

    // Update execution with runnerId and validation
    newExecution = newExecution.copyWith(
      runnerId: runnerId,
      isConfigured: isConfigured,
      validationError: isConfigured ? null : validationError,
    );
    await _persistExecution(newExecution);
    state = state.map((e) => e.id == executionId ? newExecution : e).toList();
  }

  Future<void> addPlaceholder() async {
    final placeholderId =
        'placeholder_${DateTime.now().millisecondsSinceEpoch}';
    final placeholder = ConfigExecution(
      id: placeholderId,
      configId: placeholderId,
      configName: 'Select Config',
      totalBots: -1, // Use -1 to indicate placeholder
      processedBots: 0,
      totalData: 0,
      processedData: 0,
      cpm: 0,
      good: 0,
      custom: 0,
      bad: 0,
      toCheck: 0,
      isRunning: false,
      isPlaceholder: true,
      startTime: null,
      endTime: null,
    );

    await _persistExecution(placeholder);
    state = [placeholder, ...state];
  }

  Future<void> updateProgress(
    String execId, {
    int? processedBots,
    int? processedData,
    int? cpm,
    int? good,
    int? custom,
    int? bad,
    int? toCheck,
  }) async {
    state = state.map((exec) {
      if (exec.id == execId) {
        final updated = exec.copyWith(
          processedBots: processedBots ?? exec.processedBots,
          processedData: processedData ?? exec.processedData,
          cpm: cpm ?? exec.cpm,
          good: good ?? exec.good,
          custom: custom ?? exec.custom,
          bad: bad ?? exec.bad,
          toCheck: toCheck ?? exec.toCheck,
        );
        _persistExecution(updated);
        return updated;
      }
      return exec;
    }).toList();
  }

  Future<void> updateRunnerParameters(
    String executionId, {
    String? configId,
    String? configName,
    int? totalBots,
    int? totalData,
    String? selectedWordlistId,
  }) async {
    state = state.map((exec) {
      if (exec.id == executionId || (exec.runnerId != null && exec.runnerId == executionId)) {
        final updated = exec.copyWith(
          configId: configId ?? exec.configId,
          configName: configName ?? exec.configName,
          totalBots: totalBots ?? exec.totalBots,
          totalData: totalData ?? exec.totalData,
          selectedWordlistId: selectedWordlistId ?? exec.selectedWordlistId,
          isPlaceholder: configId == null,
        );
        _persistExecution(updated);
        return updated;
      }
      return exec;
    }).toList();
  }
}
