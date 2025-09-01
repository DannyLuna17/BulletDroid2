import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/features/runner/providers/runner_provider.dart';
import 'package:bullet_droid/features/runner/models/runner_instance.dart';
import 'package:bullet_droid/features/runner/models/job_progress.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/wordlists/providers/wordlists_provider.dart';
import 'package:bullet_droid/features/dashboard/models/config_execution.dart';

/// Execution runner mapping and progress synchronization logic for the dashboard.
class ExecutionSyncService {
  final Ref ref;

  final List<ConfigExecution> Function() getState;
  final void Function(List<ConfigExecution>) setState;

  final Future<void> Function(ConfigExecution) persistExecution;
  final Future<void> Function(String) deleteExecution;

  final void Function(String executionId, String error) handleRunnerError;

  final Map<String, String> executionToRunnerIdMap = {};
  final Map<String, ProviderSubscription> progressSubscriptions = {};

  ExecutionSyncService({
    required this.ref,
    required this.getState,
    required this.setState,
    required this.persistExecution,
    required this.deleteExecution,
    required this.handleRunnerError,
  });

  void initialize() {
    ref.listen<Map<String, RunnerInstance>>(multiRunnerProvider, (
      previous,
      next,
    ) {
      if (previous != null && next.isNotEmpty) {
        // Ensure progress subscriptions are setup/maintained
        for (final entry in executionToRunnerIdMap.entries) {
          final executionId = entry.key;
          final runnerId = entry.value;
          if (next.containsKey(runnerId)) {
            if (!progressSubscriptions.containsKey(executionId)) {
              final runner = next[runnerId];
              if (runner != null && runner.isRunning) {
                subscribeToRunnerProgress(executionId, runnerId);
              }
            }
            final runner = next[runnerId];
            if (runner != null && !runner.isRunning) {
              Future.microtask(() => refreshExecutionStatus(executionId));
            }
          }
        }
        Future.microtask(() => detectAndTrackExternalRunners(previous, next));
      }
    });
  }

  void dispose() {
    for (final sub in progressSubscriptions.values) {
      sub.close();
    }
    progressSubscriptions.clear();
    executionToRunnerIdMap.clear();
  }

  Future<void> detectAndTrackExternalRunners(
    Map<String, RunnerInstance> previous,
    Map<String, RunnerInstance> current,
  ) async {
    for (final entry in current.entries) {
      final runnerId = entry.key;
      final runner = entry.value;
      if (executionToRunnerIdMap.containsValue(runnerId)) continue;
      if (runner.selectedConfigId != null && runner.isRunning) {
        final configId = runner.selectedConfigId!;
        final candidates = getState()
            .where((e) => !e.isPlaceholder && e.configId == configId)
            .toList();
        ConfigExecution? chosen;
        if (candidates.isNotEmpty) {
          chosen = candidates.firstWhere(
            (e) => e.runnerId == null || !e.isRunning,
            orElse: () => candidates.first,
          );
        }
        if (chosen != null) {
          trackExistingExecutionByExecutionId(chosen.id, runnerId);
        } else {
          await createExecutionForExternalRunner(configId, runnerId);
        }
      }
    }
  }

  void trackExistingExecutionByExecutionId(
    String executionId,
    String runnerId,
  ) {
    executionToRunnerIdMap[executionId] = runnerId;
    final updated = getState().map((exec) {
      if (exec.id == executionId && !exec.isPlaceholder) {
        final u = exec.copyWith(
          runnerId: runnerId,
          isRunning: true,
          isConfigured: true,
          validationError: null,
          startTime: DateTime.now(),
        );
        persistExecution(u);
        return u;
      }
      return exec;
    }).toList();
    setState(updated);
    subscribeToRunnerProgress(executionId, runnerId);
  }

  Future<void> createExecutionForExternalRunner(
    String configId,
    String runnerId,
  ) async {
    try {
      final configs = ref.read(configsProvider).configs;
      final config = configs.where((c) => c.id == configId).firstOrNull;
      if (config == null) return;

      final executionId =
          'auto_${configId}_${DateTime.now().millisecondsSinceEpoch}';
      final newExec = ConfigExecution(
        id: executionId,
        configId: configId,
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
        isRunning: true,
        isPlaceholder: false,
        startTime: DateTime.now(),
        runnerId: runnerId,
        isConfigured: true,
        validationError: null,
      );
      setState([...getState(), newExec]);
      await persistExecution(newExec);
      executionToRunnerIdMap[executionId] = runnerId;
      subscribeToRunnerProgress(executionId, runnerId);
    } catch (_) {}
  }

  Future<void> ensureAllExecutionsHaveRunners() async {
    final updated = <ConfigExecution>[];
    bool needsUpdate = false;
    for (final exec in getState()) {
      if (exec.isPlaceholder) {
        updated.add(exec);
        continue;
      }
      String? runnerId = executionToRunnerIdMap[exec.id] ?? exec.runnerId;
      if (runnerId == null || !executionToRunnerIdMap.containsKey(exec.id)) {
        runnerId = await createRunnerInstanceForExecution(
          exec.id,
          exec.configId,
        );
        needsUpdate = true;
        final validationError = await validateExecutionForStart(exec.id);
        final isConfigured = validationError == null;
        final u = exec.copyWith(
          runnerId: runnerId,
          isConfigured: isConfigured,
          validationError: isConfigured ? null : validationError,
        );
        await persistExecution(u);
        updated.add(u);
      } else {
        updated.add(exec);
      }
    }
    if (needsUpdate) setState(updated);
  }

  Future<void> ensureUniqueRunnersPerExecution() async {
    final Map<String, List<ConfigExecution>> byRunner = {};
    for (final exec in getState()) {
      if (exec.isPlaceholder) continue;
      final runnerId = executionToRunnerIdMap[exec.id] ?? exec.runnerId;
      if (runnerId == null) continue;
      byRunner.putIfAbsent(runnerId, () => []).add(exec);
    }

    bool changed = false;
    final List<ConfigExecution> updated = [...getState()];

    for (final entry in byRunner.entries) {
      final executions = entry.value;
      if (executions.length <= 1) continue;
      final owner = executions.firstWhere(
        (e) => e.isRunning,
        orElse: () => executions.first,
      );
      for (final exec in executions) {
        if (exec.id == owner.id) continue;
        final newRunnerId = await createRunnerInstanceForExecution(
          exec.id,
          exec.configId,
        );
        await ref
            .read(multiRunnerProvider.notifier)
            .updateSelectedConfigForRunner(newRunnerId, exec.configId);
        if (exec.selectedWordlistId != null) {
          await ref
              .read(multiRunnerProvider.notifier)
              .updateSelectedWordlistForRunner(
                newRunnerId,
                exec.selectedWordlistId,
              );
        }
        if (exec.totalBots > 0) {
          await ref
              .read(multiRunnerProvider.notifier)
              .updateBotsCountForRunner(newRunnerId, exec.totalBots);
        }
        executionToRunnerIdMap[exec.id] = newRunnerId;
        final idx = updated.indexWhere((e) => e.id == exec.id);
        if (idx != -1) {
          final u = updated[idx].copyWith(runnerId: newRunnerId);
          updated[idx] = u;
          await persistExecution(u);
        }
        changed = true;
      }
    }
    if (changed) setState(updated);
  }

  Future<String> createRunnerInstanceForExecution(
    String executionId,
    String configId,
  ) async {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final safeExecId = executionId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final runnerId = 'dashboard_${configId}_${safeExecId}_$ts';
    await ref
        .read(multiRunnerProvider.notifier)
        .initializeWithContextForRunner(
          runnerId,
          RunnerContext.configExisting,
          configId,
        );
    executionToRunnerIdMap[executionId] = runnerId;
    setState(
      getState().map((e) {
        if (e.id == executionId) {
          final u = e.copyWith(runnerId: runnerId);
          persistExecution(u);
          return u;
        }
        return e;
      }).toList(),
    );
    return runnerId;
  }

  void subscribeToRunnerProgress(String executionId, String runnerId) {
    progressSubscriptions[executionId]?.close();
    progressSubscriptions[executionId] = ref.listen(
      activeRunnerJobProgressProvider(runnerId),
      (previous, next) {
        try {
          if (next != null) {
            _syncRunnerProgressToDashboard(executionId, next);
          } else {
            _syncRunnerProgressToDashboard(executionId, null);
          }
        } catch (e) {
          handleRunnerError(executionId, 'Progress update error: $e');
        }
      },
    );
  }

  void cancelProgressSubscriptionForExecution(String executionId) {
    progressSubscriptions[executionId]?.close();
    progressSubscriptions.remove(executionId);
  }

  void _syncRunnerProgressToDashboard(
    String executionId,
    JobProgress? progress,
  ) {
    if (progress == null) {
      final runnerId = executionToRunnerIdMap[executionId];
      if (runnerId != null) {
        final runnerInstance = ref.read(runnerInstanceProvider(runnerId));
        if (runnerInstance?.finalJobProgress != null) {
          _syncRunnerProgressToDashboard(
            executionId,
            runnerInstance!.finalJobProgress,
          );
          return;
        }
      }
      return;
    }
    final updated = getState().map((exec) {
      if (exec.id == executionId) {
        final running =
            progress.status == JobStatus.running ||
            progress.status == JobStatus.preparing;

        // Compute processed as last-checked line index (1-based)
        int computedProcessed = 0;
        final String? mappedRunnerId =
            executionToRunnerIdMap[executionId] ?? exec.runnerId;
        final runnerInstance = mappedRunnerId != null
            ? ref.read(runnerInstanceProvider(mappedRunnerId))
            : null;

        if (runnerInstance != null && runnerInstance.botResults.isNotEmpty) {
          int? maxIndex;
          for (final r in runnerInstance.botResults) {
            final idx = r.currentDataIndex;
            if (idx != null && (maxIndex == null || idx > maxIndex)) {
              maxIndex = idx;
            }
          }
          if (maxIndex != null) {
            computedProcessed = maxIndex + 1;
          }
        }

        if (computedProcessed == 0) {
          final int startCount = runnerInstance?.startCount ?? 1;
          computedProcessed = (startCount - 1) + progress.processedLines;
        }
        if (computedProcessed < 0) computedProcessed = 0;
        if (exec.totalData > 0 && computedProcessed > exec.totalData) {
          computedProcessed = exec.totalData;
        }

        final u = exec.copyWith(
          isRunning: running,
          processedData: computedProcessed,
          good: progress.hits.length,
          bad: progress.fails.length,
          custom: progress.customs.length,
          toCheck: progress.toChecks.length,
          cpm: progress.cpm,
          endTime: progress.endTime,
          validationError: progress.error,
          startTime: progress.startTime,
        );
        if (progress.processedLines > 0 ||
            progress.endTime != null ||
            progress.error != null ||
            progress.status == JobStatus.completed ||
            progress.status == JobStatus.failed) {
          persistExecution(u);
        }
        if (progress.status == JobStatus.completed ||
            progress.status == JobStatus.failed ||
            progress.status == JobStatus.cancelled) {
          cancelProgressSubscriptionForExecution(executionId);
        }
        return u;
      }
      return exec;
    }).toList();
    setState(updated);
  }

  Future<String?> validateExecutionForStart(
    String executionId, {
    bool skipRunnerCreation = false,
  }) async {
    try {
      final execution = getState().firstWhere((e) => e.id == executionId);
      final configId = execution.configId;
      String? runnerId =
          executionToRunnerIdMap[executionId] ?? execution.runnerId;
      if (runnerId == null) {
        if (skipRunnerCreation) return 'Runner not initialized';
        runnerId = await createRunnerInstanceForExecution(
          executionId,
          configId,
        );
      }
      // Wait for runner instance to be available after app restart
      {
        int attempts = 0;
        const int maxAttempts = 50;
        while (attempts < maxAttempts) {
          final instance = ref.read(runnerInstanceProvider(runnerId));
          if (instance != null) break;
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      }

      var runnerInstance = ref.read(runnerInstanceProvider(runnerId));
      if (runnerInstance == null) {
        // Initialize missing runner instance with the same persisted runnerId
        await ref
            .read(multiRunnerProvider.notifier)
            .initializeWithContextForRunner(
              runnerId,
              RunnerContext.configExisting,
              configId,
            );
        // Wait briefly for creation to reflect
        int attempts = 0;
        const int maxAttempts = 30;
        while (attempts < maxAttempts) {
          runnerInstance = ref.read(runnerInstanceProvider(runnerId));
          if (runnerInstance != null) break;
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
        if (runnerInstance == null) return 'Runner instance not found';
      }
      if (runnerInstance.selectedConfigId != configId) {
        await ref
            .read(multiRunnerProvider.notifier)
            .updateSelectedConfigForRunner(runnerId, configId);
      }
      var updatedRunner = ref.read(runnerInstanceProvider(runnerId));
      // Apply execution-stored parameters if runner lacks them
      final executionState = getState().firstWhere((e) => e.id == executionId);
      if (updatedRunner?.selectedWordlistId == null &&
          executionState.selectedWordlistId != null) {
        await ref
            .read(multiRunnerProvider.notifier)
            .updateSelectedWordlistForRunner(
              runnerId,
              executionState.selectedWordlistId,
            );
        updatedRunner = ref.read(runnerInstanceProvider(runnerId));
      }
      if ((updatedRunner?.botsCount ?? 0) <= 0 &&
          executionState.totalBots > 0) {
        await ref
            .read(multiRunnerProvider.notifier)
            .updateBotsCountForRunner(runnerId, executionState.totalBots);
        updatedRunner = ref.read(runnerInstanceProvider(runnerId));
      }
      // Ensure configs/wordlists providers are loaded before validation
      {
        int attempts = 0;
        const int maxAttempts = 50;
        while (attempts < maxAttempts) {
          final configsState = ref.read(configsProvider);
          final wordlistsState = ref.read(wordlistsProvider);
          if (!configsState.isLoading && !wordlistsState.isLoading) {
            break;
          }
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      }
      // Re-read runner after potential async updates
      updatedRunner = ref.read(runnerInstanceProvider(runnerId));
      if (updatedRunner?.hasActiveJob == true) {
        return 'Runner is already running';
      }
      if (updatedRunner?.selectedConfigId == null) {
        return 'Please configure runner first. Go to Runner screen to set up configuration.';
      }
      if (updatedRunner?.selectedWordlistId == null) {
        return 'Please configure runner first. Go to Runner screen to set up wordlist.';
      }
      if ((updatedRunner?.botsCount ?? 0) <= 0) {
        return 'Please configure runner first. Go to Runner screen to set up bot count.';
      }

      final configs = ref.read(configsProvider).configs;
      final config = configs
          .where((c) => c.id == updatedRunner?.selectedConfigId)
          .firstOrNull;
      if (config == null) return 'Config not found';
      if (!File(config.filePath).existsSync()) {
        return 'Config file does not exist: ${config.filePath}';
      }

      final wordlists = ref.read(wordlistsProvider).wordlists;
      final wordlist = wordlists
          .where((w) => w.id == updatedRunner?.selectedWordlistId)
          .firstOrNull;
      if (wordlist == null) return 'Wordlist not found';
      if (!File(wordlist.path).existsSync()) {
        return 'Wordlist file does not exist: ${wordlist.path}';
      }

      return null;
    } catch (e) {
      return 'Validation error: ${e.toString()}';
    }
  }

  Future<void> refreshExecutionStatus(String executionId) async {
    final exec = getState().firstWhere((e) => e.id == executionId);
    String? runnerId = executionToRunnerIdMap[executionId] ?? exec.runnerId;
    runnerId ??= await createRunnerInstanceForExecution(
      executionId,
      exec.configId,
    );
    final validationError = await validateExecutionForStart(
      executionId,
      skipRunnerCreation: true,
    );
    final isConfigured = validationError == null;
    final updated = getState().map((e) {
      if (e.id == executionId) {
        final u = e.copyWith(
          runnerId: runnerId,
          isConfigured: isConfigured,
          validationError: isConfigured ? null : validationError,
        );
        persistExecution(u);
        return u;
      }
      return e;
    }).toList();
    setState(updated);
  }
}
