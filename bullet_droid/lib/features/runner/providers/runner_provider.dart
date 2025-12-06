import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:bullet_droid/features/runner/services/isolate_pool_service.dart';
import 'package:bullet_droid/features/runner/services/job_recovery_service.dart';
import 'package:bullet_droid/features/runner/models/job_params.dart';
import 'package:bullet_droid/features/runner/models/job_progress.dart';
import 'package:bullet_droid/features/runner/models/runner_instance.dart';

import 'package:bullet_droid/shared/providers/hive_provider.dart';
import 'package:bullet_droid/features/hits_db/providers/hits_db_provider.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/wordlists/providers/wordlists_provider.dart';
import 'package:bullet_droid/features/dashboard/providers/dashboard_provider.dart';
import 'package:bullet_droid/features/settings/providers/settings_provider.dart';
import 'package:bullet_droid/core/services/toast_service.dart';
import 'package:bullet_droid/core/services/background_service.dart';
import 'package:bullet_droid/core/utils/logging.dart';

// Enumeration for runner navigation contexts
enum RunnerContext { placeholder, configNew, configExisting }

// Provider for isolate pool service
final isolatePoolProvider = Provider<IsolatePoolService>((ref) {
  final service = IsolatePoolService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider for multi-runner state
final multiRunnerProvider =
    StateNotifierProvider<MultiRunnerNotifier, Map<String, RunnerInstance>>((
      ref,
    ) {
      final isolatePool = ref.watch(isolatePoolProvider);
      final jobHistoryBox = ref.watch(jobHistoryBoxProvider);
      final jobRecoveryService = JobRecoveryService();
      return MultiRunnerNotifier(
        isolatePool,
        jobHistoryBox,
        jobRecoveryService,
        ref,
      );
    });

// Provider for specific runner instance
final runnerInstanceProvider = Provider.family<RunnerInstance?, String>((
  ref,
  runnerId,
) {
  final allRunners = ref.watch(multiRunnerProvider);
  return allRunners[runnerId];
});

// Provider for active job progress for specific runner
final activeRunnerJobProgressProvider = Provider.family<JobProgress?, String>((
  ref,
  runnerId,
) {
  final runnerInstance = ref.watch(runnerInstanceProvider(runnerId));

  if (runnerInstance?.jobId == null) {
    final finalProgress = runnerInstance?.finalJobProgress;
    return finalProgress;
  }

  final currentProgress = runnerInstance?.currentJobProgress;
  return currentProgress;
});

// Provider for live statistics for specific runner
final runnerLiveStatsProvider = Provider.family<LiveStats?, String>((
  ref,
  runnerId,
) {
  final progress = ref.watch(activeRunnerJobProgressProvider(runnerId));
  if (progress == null) return null;

  return LiveStats.fromJobProgress(progress);
});

// Live statistics class
class LiveStats {
  final int cpm;
  final Map<String, int> proxyStats;
  final Map<String, int> dataStats;

  LiveStats({
    required this.cpm,
    required this.proxyStats,
    required this.dataStats,
  });

  factory LiveStats.fromJobProgress(JobProgress progress) {
    return LiveStats(
      cpm: progress.cpm,
      proxyStats: {'untested': 0, 'good': 0, 'bad': 0, 'banned': 0},
      dataStats: {
        'pending': progress.totalLines - progress.processedLines,
        'success': progress.hits.length,
        'custom': progress.customs.length,
        'failed': progress.fails.length,
        'tocheck': progress.toChecks
            .where((r) => r.status == BotStatus.TOCHECK)
            .length,
        'retry': progress.toChecks
            .where((r) => r.status == BotStatus.RETRY)
            .length,
      },
    );
  }
}

// Multi-Runner Notifier class
class MultiRunnerNotifier extends StateNotifier<Map<String, RunnerInstance>> {
  final IsolatePoolService _isolatePool;
  final Box _jobHistoryBox;
  final JobRecoveryService _jobRecoveryService;
  final Ref _ref;
  Box? _settingsBox;

  final Map<String, Set<String>> _processedHits = {};

  // Track detailed proxy states for each runner
  final Map<String, Map<String, ProxyState>> _runnerProxyStates = {};

  final Set<String> _completedJobs = {};

  MultiRunnerNotifier(
    this._isolatePool,
    this._jobHistoryBox,
    this._jobRecoveryService,
    this._ref,
  ) : super({}) {
    _initialize();
  }

  // Get specific runner instance
  RunnerInstance? getRunner(String runnerId) {
    return state[runnerId];
  }

  // Create or get runner instance
  RunnerInstance getOrCreateRunner(String runnerId) {
    if (state.containsKey(runnerId)) {
      return state[runnerId]!;
    }

    final newRunner = _jobRecoveryService.createRunner(runnerId);
    state = {...state, runnerId: newRunner};
    return newRunner;
  }

  Future<void> _initialize() async {
    try {
      // Add timeout to isolate pool initialization
      await _isolatePool.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'IsolatePool initialization timeout',
            const Duration(seconds: 10),
          );
        },
      );

      // Open settings box for persisting runner parameters
      _settingsBox = await Hive.openBox('runner_settings').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException(
            'Settings box timeout',
            const Duration(seconds: 5),
          );
        },
      );

      // Load existing runners from recovery service
      state = _jobRecoveryService.allRunners;

      // Listen to progress updates to save job history
      _isolatePool.progressStream.listen((progress) async {
        final runnerId = progress.runnerId;

        if (runnerId == null || !state.containsKey(runnerId)) {
          return;
        }

        final currentRunner = state[runnerId]!;
        final bool runnerActive = currentRunner.hasActiveJob;
        final bool isTerminal =
            progress.status == JobStatus.completed ||
            progress.status == JobStatus.failed ||
            progress.status == JobStatus.cancelled;

        if (!runnerActive && !isTerminal) {
          return;
        }

        if (runnerActive &&
            currentRunner.jobId != null &&
            currentRunner.jobId != progress.jobId) {
          return;
        }

        _updateJobHistory(progress);

        final updatedRunner = currentRunner
            .updateProgress(
              currentCpm: progress.cpm,
              dataStats: {
                'pending': progress.totalLines - progress.processedLines,
                'success': progress.hits.length,
                'custom': progress.customs.length,
                'failed': progress.fails.length,
                'tocheck': progress.toChecks
                    .where((r) => r.status == BotStatus.TOCHECK)
                    .length,
                'retry': progress.toChecks
                    .where((r) => r.status == BotStatus.RETRY)
                    .length,
              },
            )
            .copyWith(currentJobProgress: progress);

        state = {...state, runnerId: updatedRunner};
        _jobRecoveryService.updateRunner(runnerId, updatedRunner);

        // Update dashboard with live progress
        _updateDashboard(runnerId, progress);

        // Capture hits to database
        _captureHitsToDatabase(progress);

        if (isTerminal) {
          final bool resetStart = progress.status == JobStatus.completed;
          final stoppedRunner = updatedRunner
              .stopJob(finalProgress: progress)
              .copyWith(startCount: resetStart ? 1 : updatedRunner.startCount);
          state = {...state, runnerId: stoppedRunner};
          _jobRecoveryService.updateRunner(runnerId, stoppedRunner);
          _jobRecoveryService.onJobCompleted(progress.jobId);

          // Show completion toast notification
          final configName = _getConfigName(stoppedRunner.selectedConfigId);
          _showCompletionToast(progress, configName);

          await _syncForegroundService();
          await BackgroundService.showCompletion(configName);
        } else {
          await _syncForegroundService();
        }
      });

      // Listen to bot result updates
      _isolatePool.botResultsStream.listen((botUpdate) {
        final runnerId = botUpdate.runnerId;
        if (runnerId == null || !state.containsKey(runnerId)) {
          return;
        }

        final currentRunner = state[runnerId]!;

        // Ignore bot updates if runner is not running or jobId does not match
        if (!currentRunner.hasActiveJob ||
            currentRunner.jobId != botUpdate.jobId) {
          return;
        }

        final currentResults = [...currentRunner.botResults];

        for (final newResult in botUpdate.botResults) {
          if (newResult.botId < 1 ||
              newResult.botId > currentRunner.botsCount) {
            continue;
          }
          final existingIndex = currentResults.indexWhere(
            (r) => r.botId == newResult.botId,
          );
          if (existingIndex >= 0) {
            currentResults[existingIndex] = newResult;
          } else {
            currentResults.add(newResult);
          }
        }

        final updatedRunner = currentRunner.updateProgress(
          botResults: currentResults,
        );
        state = {...state, runnerId: updatedRunner};
        _jobRecoveryService.updateRunner(runnerId, updatedRunner);
      });

      // Listen to proxy updates
      _isolatePool.proxyUpdatesStream.listen((proxyUpdate) {
        final runnerId = proxyUpdate.runnerId;
        if (runnerId == null || !state.containsKey(runnerId)) {
          return;
        }

        final currentRunner = state[runnerId]!;

        // Ignore proxy updates if runner is not running or jobId does not match
        if (!currentRunner.hasActiveJob ||
            currentRunner.jobId != proxyUpdate.jobId) {
          return;
        }

        // Update tracked proxy states
        final runnerProxyStates = _runnerProxyStates[runnerId] ?? {};
        for (final proxy in proxyUpdate.proxies) {
          runnerProxyStates[proxy.proxy] = proxy.state;
        }
        _runnerProxyStates[runnerId] = runnerProxyStates;

        // Calculate stats from full state map
        int untested = 0;
        int good = 0;
        int bad = 0;
        int banned = 0;

        for (final state in runnerProxyStates.values) {
          switch (state) {
            case ProxyState.untested:
              untested++;
              break;
            case ProxyState.good:
              good++;
              break;
            case ProxyState.bad:
              bad++;
              break;
            case ProxyState.banned:
              banned++;
              break;
          }
        }

        final Map<String, int> newProxyStats = {
          'untested': untested,
          'good': good,
          'bad': bad,
          'banned': banned,
        };

        final updatedRunner = currentRunner.updateProgress(
          proxyStats: newProxyStats,
        );
        state = {...state, runnerId: updatedRunner};
        _jobRecoveryService.updateRunner(runnerId, updatedRunner);
      });
    } catch (e) {
      Log.w('Error initializing multi-runner: $e');

      if (e is TimeoutException) {
        Log.w(
          'Multi-runner initialization timed out, continuing with existing state',
        );
      } else {
        Log.e('Multi-runner initialization failed: $e');
      }
    }
  }

  /// Update dashboard card parameters based on the current runner state
  Future<void> updateDashboardParametersFromRunner(String runnerId) async {
    try {
      final runnerInstance = state[runnerId];
      if (runnerInstance == null) return;

      // Resolve config name
      final configName = _resolveDashboardConfigName(
        runnerInstance.selectedConfigId,
      );

      // Resolve total data from selected wordlist
      final totalData = _resolveWordlistTotalLines(
        runnerInstance.selectedWordlistId,
      );

      final shouldBePlaceholder = runnerInstance.selectedConfigId == null;

      _ref
          .read(configExecutionsProvider.notifier)
          .updateRunnerParameters(
            runnerId,
            configId: shouldBePlaceholder
                ? null
                : runnerInstance.selectedConfigId,
            configName: configName,
            totalBots: runnerInstance.botsCount,
            totalData: totalData,
            selectedWordlistId: runnerInstance.selectedWordlistId,
          );
    } catch (e) {}
  }

  String _resolveDashboardConfigName(String? configId) {
    if (configId == null) return 'Select Config';
    try {
      final configs = _ref.read(configsProvider).configs;
      final cfg = configs.firstWhere((c) => c.id == configId);
      return cfg.name;
    } catch (_) {
      return 'Select Config';
    }
  }

  int _resolveWordlistTotalLines(String? wordlistId) {
    if (wordlistId == null) return 0;
    try {
      final wordlists = _ref.read(wordlistsProvider).wordlists;
      final wl = wordlists.firstWhere((w) => w.id == wordlistId);
      return wl.totalLines;
    } catch (_) {
      return 0;
    }
  }

  RunnerInstance _loadParametersForContext(
    String runnerId,
    RunnerContext context,
    String? configId,
  ) {
    if (_settingsBox == null) {
      return _jobRecoveryService.createRunner(runnerId);
    }

    switch (context) {
      case RunnerContext.placeholder:
        return RunnerInstance(
          runnerId: runnerId,
          isInitialized: true,
          lastActivity: DateTime.now(),
        );

      case RunnerContext.configNew:
        return RunnerInstance(
          runnerId: runnerId,
          isInitialized: true,
          selectedConfigId: configId,
          lastActivity: DateTime.now(),
        );

      case RunnerContext.configExisting:
        // Try to recover existing runner or create with saved settings
        final existingRunner = _jobRecoveryService.getRunner(runnerId);
        if (existingRunner != null) {
          return existingRunner.copyWith(lastActivity: DateTime.now());
        }

        // Create new runner with saved settings
        return RunnerInstance(
          runnerId: runnerId,
          isInitialized: true,
          selectedConfigId: _settingsBox!.get('selectedConfigId_$runnerId'),
          selectedWordlistId: _settingsBox!.get('selectedWordlistId_$runnerId'),
          selectedProxies: _settingsBox!.get(
            'selectedProxies_$runnerId',
            defaultValue: 'Default',
          ),
          useProxies: _settingsBox!.get(
            'useProxies_$runnerId',
            defaultValue: true,
          ),
          startCount: _settingsBox!.get(
            'startCount_$runnerId',
            defaultValue: 1,
          ),
          botsCount: _settingsBox!.get('botsCount_$runnerId', defaultValue: 1),
          lastActivity: DateTime.now(),
        );
    }
  }

  Future<RunnerInstance> _handleConfigIdInitialization(
    String runnerId,
    RunnerInstance runner,
    String configId,
  ) async {
    try {
      int attempts = 0;
      const maxAttempts = 50;
      const delayMs = 100;

      while (attempts < maxAttempts) {
        final configsState = _ref.read(configsProvider);
        if (!configsState.isLoading && configsState.configs.isNotEmpty) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: delayMs));
        attempts++;
      }

      final configs = _ref.read(configsProvider).configs;
      configs.firstWhere((c) => c.id == configId); // Validate config exists

      // Set the selected config
      var updatedRunner = runner.copyWith(selectedConfigId: configId);

      // Auto-select first available wordlist if none is set
      updatedRunner = await _loadSavedWordlistForConfig(
        runnerId,
        updatedRunner,
        configId,
      );

      if (updatedRunner.selectedProxies == 'Default') {
        final shouldUseProxies = _getConfigProxyRequirement(configId);
        updatedRunner = updatedRunner.copyWith(useProxies: shouldUseProxies);
      }

      // Save parameters after initialization
      await _saveRunnerParameters(runnerId, updatedRunner);

      return updatedRunner;
    } catch (e) {
      return runner;
    }
  }

  Future<RunnerInstance> _loadSavedWordlistForConfig(
    String runnerId,
    RunnerInstance runner,
    String configId,
  ) async {
    try {
      int attempts = 0;
      const maxAttempts = 50;
      const delayMs = 100;

      while (attempts < maxAttempts) {
        final wordlistsState = _ref.read(wordlistsProvider);
        if (!wordlistsState.isLoading && wordlistsState.wordlists.isNotEmpty) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: delayMs));
        attempts++;
      }

      final wordlists = _ref.read(wordlistsProvider).wordlists;

      if (runner.selectedWordlistId == null && wordlists.isNotEmpty) {
        return runner.copyWith(selectedWordlistId: wordlists.first.id);
      }

      return runner;
    } catch (e) {
      Log.w('Could not load wordlist for config $configId: $e');
      return runner;
    }
  }

  Future<void> _saveRunnerParameters(
    String runnerId,
    RunnerInstance runner,
  ) async {
    if (_settingsBox == null) return;

    await _settingsBox!.putAll({
      'selectedConfigId_$runnerId': runner.selectedConfigId,
      'selectedWordlistId_$runnerId': runner.selectedWordlistId,
      'selectedProxies_$runnerId': runner.selectedProxies,
      'useProxies_$runnerId': runner.useProxies,
      'startCount_$runnerId': runner.startCount,
      'botsCount_$runnerId': runner.botsCount,
    });
  }

  Future<void> startJobForRunner(String runnerId, JobParams params) async {
    // Check if system can accept new job
    if (!_jobRecoveryService.canAcceptNewJob) {
      throw Exception(
        'Concurrent runner limit reached (${JobRecoveryService.maxConcurrentRunners}). Try again shortly.',
      );
    }

    // Get or create runner instance
    final runner = getOrCreateRunner(runnerId);

    if (runner.hasActiveJob) {
      throw Exception('Runner already has an active job');
    }

    if (!runner.isInitialized) {
      throw Exception('Runner not initialized');
    }

    // Ensure isolate pool has workers available
    try {
      if (!_isolatePool.hasAvailableWorkers) {
        await _isolatePool.initialize();

        if (!_isolatePool.hasAvailableWorkers) {
          throw Exception(
            'Isolate pool has no available workers. Try restarting the app.',
          );
        }
      } else {}
    } catch (e) {
      throw Exception('Failed to prepare workers: ${e.toString()}');
    }

    // Clear previous job tracking data for clean slate
    _clearPreviousJobData(runnerId);

    // Initialize proxy tracking if proxies are used
    if (params.useProxies) {
      _runnerProxyStates[runnerId] = {
        for (var p in params.proxies) p: ProxyState.untested,
      };
    } else {
      _runnerProxyStates.remove(runnerId);
    }

    try {
      final jobId = await _isolatePool.startJob(params, runnerId: runnerId);
      Log.i('Started job $jobId for runner=$runnerId');

      // Update runner with job information
      final updatedRunner = runner
          .startJob(jobId)
          .copyWith(
            botsCount: params.threads,
            dataStats: {
              'pending': params.dataLines.length,
              'success': 0,
              'custom': 0,
              'failed': 0,
              'tocheck': 0,
              'retry': 0,
            },
          );

      state = {...state, runnerId: updatedRunner};
      _jobRecoveryService.associateJobWithRunner(jobId, runnerId);

      // Create initial job history entry
      await _jobHistoryBox.put(jobId, {
        'jobId': jobId,
        'runnerId': runnerId,
        'configId': params.configId,
        'configName': _getConfigName(params.configId),
        'status': 'running',
        'timestamp': DateTime.now().toIso8601String(),
        'totalLines': params.dataLines.length,
        'processedLines': 0,
        'hits': 0,
        'fails': 0,
        'customs': 0,
        'toChecks': 0,
        'cpm': 0,
      });

      // Start/update Android foreground service notification reflecting active runners
      await _syncForegroundService();
    } catch (e) {
      final failedRunner = runner.copyWith(
        error: 'Failed to start job: ${e.toString()}',
      );
      state = {...state, runnerId: failedRunner};
      _jobRecoveryService.updateRunner(runnerId, failedRunner);

      rethrow;
    }
  }

  Future<void> stopJobForRunner(String runnerId) async {
    final runner = state[runnerId];
    if (runner == null || !runner.hasActiveJob) return;

    try {
      await _isolatePool.stopJob(runner.jobId!);
      final JobProgress? current = runner.currentJobProgress;
      final JobProgress cancelledProgress = current != null
          ? current.copyWith(
              status: JobStatus.cancelled,
              endTime: DateTime.now(),
            )
          : JobProgress(
              jobId: runner.jobId!,
              runnerId: runnerId,
              configId: runner.selectedConfigId ?? 'unknown',
              status: JobStatus.cancelled,
              startTime: DateTime.now(),
              endTime: DateTime.now(),
            );

      final int processedIncrement = current?.processedLines ?? 0;
      final int newStartCount = (runner.startCount + processedIncrement) < 1
          ? 1
          : runner.startCount + processedIncrement;

      final stoppedRunner = runner
          .stopJob(finalProgress: cancelledProgress)
          .copyWith(startCount: newStartCount);
      state = {...state, runnerId: stoppedRunner};
      _jobRecoveryService.updateRunner(runnerId, stoppedRunner);

      if (runner.jobId != null) {
        _jobRecoveryService.onJobCompleted(runner.jobId!);
      }

      // Update/stop foreground service if no runners remain
      await _syncForegroundService();
    } catch (e) {
      final errorRunner = runner.copyWith(
        error: 'Failed to stop job: ${e.toString()}',
      );
      state = {...state, runnerId: errorRunner};
      _jobRecoveryService.updateRunner(runnerId, errorRunner);
    }
  }

  /// Keep Android foreground service notification in sync with active runner count
  Future<void> _syncForegroundService() async {
    final activeRunnerCount = state.values.where((r) => r.hasActiveJob).length;
    await BackgroundService.syncWithActiveRunnerCount(activeRunnerCount);
  }

  void _updateJobHistory(JobProgress progress) async {
    final jobData = _jobHistoryBox.get(progress.jobId);
    if (jobData != null) {
      final updatedData = Map<String, dynamic>.from(jobData);
      updatedData['status'] = progress.status.name;
      updatedData['processedLines'] = progress.processedLines;
      updatedData['hits'] = progress.hits.length;
      updatedData['fails'] = progress.fails.length;
      updatedData['customs'] = progress.customs.length;
      updatedData['toChecks'] = progress.toChecks.length;
      updatedData['cpm'] = progress.cpm;

      if (progress.endTime != null) {
        updatedData['endTime'] = progress.endTime!.toIso8601String();
      }

      if (progress.error != null) {
        updatedData['error'] = progress.error;
      }

      await _jobHistoryBox.put(progress.jobId, updatedData);
    }
  }

  // Parameter update methods for specific runner
  Future<void> updateSelectedConfigForRunner(
    String runnerId,
    String? configId,
  ) async {
    final runner = getOrCreateRunner(runnerId);
    final updatedRunner = runner.copyWith(selectedConfigId: configId);

    state = {...state, runnerId: updatedRunner};
    _jobRecoveryService.updateRunner(runnerId, updatedRunner);
    await _saveRunnerParameters(runnerId, updatedRunner);
  }

  // Initialize with specific config ID
  Future<void> initializeWithConfigIdForRunner(
    String runnerId,
    String configId,
  ) async {
    final runner = getOrCreateRunner(runnerId);

    if (!runner.isFullyInitialized) {
      final initializedRunner = runner.copyWith(isInitialized: true);
      state = {...state, runnerId: initializedRunner};
      _jobRecoveryService.updateRunner(runnerId, initializedRunner);
    }

    final configuredRunner = await _handleConfigIdInitialization(
      runnerId,
      state[runnerId]!,
      configId,
    );
    state = {...state, runnerId: configuredRunner};
    _jobRecoveryService.updateRunner(runnerId, configuredRunner);
  }

  // Initialize with context-aware parameters based on navigation source
  Future<void> initializeWithContextForRunner(
    String runnerId,
    RunnerContext context,
    String? configId,
  ) async {
    var runner = _loadParametersForContext(runnerId, context, configId);

    // If configId is provided and context requires config handling, initialize it
    if (configId != null &&
        (context == RunnerContext.configNew ||
            context == RunnerContext.configExisting)) {
      runner = await _handleConfigIdInitialization(runnerId, runner, configId);
    }

    // Try to recover job if existing context
    if (context == RunnerContext.configExisting) {
      final recoveredRunner = await _jobRecoveryService.recoverRunnerJob(
        runnerId,
        _isolatePool,
      );
      if (recoveredRunner != null) {
        // Preserve the config and wordlist we just set, but take other recovery data
        runner = recoveredRunner.copyWith(
          selectedConfigId: runner.selectedConfigId,
          selectedWordlistId: runner.selectedWordlistId,
        );
      }
    }

    _jobRecoveryService.updateRunner(runnerId, runner);
    final finalRunner = _jobRecoveryService.getRunner(runnerId) ?? runner;
    state = {...state, runnerId: finalRunner};
  }

  Future<void> updateSelectedWordlistForRunner(
    String runnerId,
    String? wordlistId,
  ) async {
    final runner = getOrCreateRunner(runnerId);
    final updatedRunner = runner.copyWith(selectedWordlistId: wordlistId);

    state = {...state, runnerId: updatedRunner};
    _jobRecoveryService.updateRunner(runnerId, updatedRunner);
    await _saveRunnerParameters(runnerId, updatedRunner);
  }

  Future<void> updateSelectedProxiesForRunner(
    String runnerId,
    String proxies,
  ) async {
    final runner = getOrCreateRunner(runnerId);

    // Determine actual proxy usage based on selection
    bool useProxies;
    if (proxies == 'Default') {
      useProxies = _getConfigProxyRequirement(runner.selectedConfigId);
    } else if (proxies == 'Off') {
      useProxies = false;
    } else if (proxies == 'On') {
      useProxies = true;
    } else {
      // Fallback for any unexpected values
      useProxies = false;
    }

    final updatedRunner = runner.copyWith(
      selectedProxies: proxies,
      useProxies: useProxies,
    );

    state = {...state, runnerId: updatedRunner};
    _jobRecoveryService.updateRunner(runnerId, updatedRunner);
    await _saveRunnerParameters(runnerId, updatedRunner);
  }

  /// Helper method to get proxy requirement from config
  bool _getConfigProxyRequirement(String? configId) {
    if (configId == null) return false;

    try {
      final configsState = _ref.read(configsProvider);
      final config = configsState.configs.firstWhere((c) => c.id == configId);
      return config.metadata['needsProxies'] as bool? ?? false;
    } catch (e) {
      Log.w('Could not read proxy requirement from config: $e');
      return false;
    }
  }

  Future<void> updateUseProxiesForRunner(
    String runnerId,
    bool useProxies,
  ) async {
    final runner = getOrCreateRunner(runnerId);
    final updatedRunner = runner.copyWith(useProxies: useProxies);

    state = {...state, runnerId: updatedRunner};
    _jobRecoveryService.updateRunner(runnerId, updatedRunner);
    await _saveRunnerParameters(runnerId, updatedRunner);
  }

  Future<void> updateStartCountForRunner(
    String runnerId,
    int startCount,
  ) async {
    final runner = getOrCreateRunner(runnerId);
    final updatedRunner = runner.copyWith(startCount: startCount);

    state = {...state, runnerId: updatedRunner};
    _jobRecoveryService.updateRunner(runnerId, updatedRunner);
    await _saveRunnerParameters(runnerId, updatedRunner);
  }

  Future<void> updateBotsCountForRunner(String runnerId, int botsCount) async {
    final runner = getOrCreateRunner(runnerId);
    final updatedRunner = runner.copyWith(botsCount: botsCount);

    state = {...state, runnerId: updatedRunner};
    _jobRecoveryService.updateRunner(runnerId, updatedRunner);
    await _saveRunnerParameters(runnerId, updatedRunner);
  }

  /// Capture hits to database
  Future<void> _captureHitsToDatabase(JobProgress progress) async {
    try {
      // Skip if we've already processed this completed job
      if (_completedJobs.contains(progress.jobId)) {
        return;
      }

      final runnerId = _jobRecoveryService.getRunnerForJob(progress.jobId);
      if (runnerId == null || !state.containsKey(runnerId)) {
        return;
      }

      final runner = state[runnerId]!;
      final hitsDbNotifier = _ref.read(hitsDbProvider.notifier);
      final configsState = _ref.read(configsProvider);
      final wordlistsState = _ref.read(wordlistsProvider);

      // Initialize tracking for this job if not exists
      if (!_processedHits.containsKey(progress.jobId)) {
        _processedHits[progress.jobId] = <String>{};
      }

      final processedSet = _processedHits[progress.jobId]!;

      // Get config and wordlist info
      String configName = 'Unknown';
      String wordlistName = 'Unknown';
      String wordlistId = 'unknown';

      if (runner.selectedConfigId != null) {
        try {
          final config = configsState.configs.firstWhere(
            (c) => c.id == runner.selectedConfigId,
          );
          configName = config.name;
        } catch (e) {
          // Config not found, use default
        }
      }

      if (runner.selectedWordlistId != null) {
        try {
          final wordlist = wordlistsState.wordlists.firstWhere(
            (w) => w.id == runner.selectedWordlistId,
          );
          wordlistName = wordlist.name;
          wordlistId = wordlist.id;
        } catch (e) {
          // Wordlist not found, use default
        }
      }

      // Helper function to create unique key for hit
      String createHitKey(ValidDataResult hit) {
        return '${hit.data}_${hit.status.name}_${hit.completionTime.millisecondsSinceEpoch}';
      }

      // Capture hits
      for (final hit in progress.hits) {
        final hitKey = createHitKey(hit);
        if (!processedSet.contains(hitKey)) {
          await hitsDbNotifier.addHitFromJobProgress(
            hit,
            runner.selectedConfigId ?? 'unknown',
            configName,
            wordlistId,
            wordlistName,
            progress.jobId,
          );
          processedSet.add(hitKey);
        }
      }

      // Capture customs
      for (final custom in progress.customs) {
        final customKey = createHitKey(custom);
        if (!processedSet.contains(customKey)) {
          await hitsDbNotifier.addHitFromJobProgress(
            custom,
            runner.selectedConfigId ?? 'unknown',
            configName,
            wordlistId,
            wordlistName,
            progress.jobId,
          );
          processedSet.add(customKey);
        }
      }

      // Capture toChecks
      for (final toCheck in progress.toChecks) {
        final toCheckKey = createHitKey(toCheck);
        if (!processedSet.contains(toCheckKey)) {
          await hitsDbNotifier.addHitFromJobProgress(
            toCheck,
            runner.selectedConfigId ?? 'unknown',
            configName,
            wordlistId,
            wordlistName,
            progress.jobId,
          );
          processedSet.add(toCheckKey);
        }
      }

      // Mark job as completed and clean up tracking
      if (progress.status == JobStatus.completed ||
          progress.status == JobStatus.failed ||
          progress.status == JobStatus.cancelled) {
        _completedJobs.add(progress.jobId);
        _processedHits.remove(progress.jobId);
      }
      await _syncForegroundService();
    } catch (e) {}
  }

  // Clean up inactive runners
  void cleanupInactiveRunners() {
    _jobRecoveryService.cleanupInactiveRunners();
    state = _jobRecoveryService.allRunners;
  }

  // Remove specific runner
  void removeRunner(String runnerId) {
    final runner = state[runnerId];
    if (runner?.hasActiveJob == true) {
      // Stop active job before removing
      stopJobForRunner(runnerId);
    }

    final newState = Map<String, RunnerInstance>.from(state);
    newState.remove(runnerId);
    state = newState;

    _jobRecoveryService.removeRunner(runnerId);
    _runnerProxyStates.remove(runnerId);
  }

  /// Update dashboard with live progress
  Future<void> _updateDashboard(String runnerId, JobProgress progress) async {
    try {
      final dashboardNotifier = _ref.read(configExecutionsProvider.notifier);
      final computedProcessed = _computeProcessedForDashboard(
        runnerId,
        progress,
      );

      dashboardNotifier.updateProgress(
        runnerId,
        cpm: progress.cpm,
        good: progress.hits.length,
        custom: progress.customs.length,
        bad: progress.fails.length,
        toCheck: progress.toChecks.length,
        processedData: computedProcessed,
      );

      await _syncForegroundService();
    } catch (e) {}
  }

  int _computeProcessedForDashboard(String runnerId, JobProgress progress) {
    int computedProcessed = 0;
    final currentRunner = state[runnerId];
    if (currentRunner != null && currentRunner.botResults.isNotEmpty) {
      int? maxIndex;
      for (final r in currentRunner.botResults) {
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
      final int startCount = currentRunner?.startCount ?? 1;
      computedProcessed = (startCount - 1) + progress.processedLines;
      if (computedProcessed < 0) computedProcessed = 0;
    }
    return computedProcessed;
  }

  /// Helper method to safely retrieve config name
  String _getConfigName(String? configId) {
    if (configId == null) return 'Unknown Config';

    try {
      final configs = _ref.read(configsProvider).configs;
      final config = configs.firstWhere((c) => c.id == configId);
      return config.name;
    } catch (e) {
      return 'Unknown Config';
    }
  }

  /// Helper method to format completion message based on job status
  String _formatCompletionMessage(JobProgress progress, String configName) {
    switch (progress.status) {
      case JobStatus.completed:
        return '$configName completed • ${progress.hits.length} hits • ${progress.processedLines} processed';
      case JobStatus.failed:
        final errorSummary =
            progress.error?.split('\n').first ?? 'Unknown error';
        return '$configName failed • $errorSummary';
      case JobStatus.cancelled:
        return '$configName cancelled • ${progress.processedLines} processed';
      default:
        return '$configName finished';
    }
  }

  /// Helper method to show completion toast with appropriate variant
  void _showCompletionToast(JobProgress progress, String configName) {
    try {
      // Check if notifications are enabled in settings
      final settings = _ref.read(settingsProvider);
      if (!settings.enableNotifications) {
        return;
      }

      final message = _formatCompletionMessage(progress, configName);
      const duration = Duration(seconds: 5);

      switch (progress.status) {
        case JobStatus.completed:
          ToastService.showSuccess(message, duration: duration);
          break;
        case JobStatus.failed:
          ToastService.showError(message, duration: duration);
          break;
        case JobStatus.cancelled:
          ToastService.showInfo(message, duration: duration);
          break;
        default:
          ToastService.showInfo(message, duration: duration);
      }
    } catch (e) {}
  }

  /// Helper method to clear previous job tracking data for clean slate
  void _clearPreviousJobData(String runnerId) {
    try {
      // Find and remove any completed job IDs associated with this runner
      final runner = state[runnerId];
      if (runner?.finalJobProgress?.jobId != null) {
        final previousJobId = runner!.finalJobProgress!.jobId;
        _completedJobs.remove(previousJobId);
        _processedHits.remove(previousJobId);
      }

      // Clear final job progress from JobRecoveryService separate storage
      _jobRecoveryService.clearFinalJobProgress(runnerId);

      // Also clean up any orphaned tracking data for this runner
      final keysToRemove = <String>[];
      for (final jobId in _processedHits.keys) {
        final associatedRunnerId = _jobRecoveryService.getRunnerForJob(jobId);
        if (associatedRunnerId == runnerId) {
          keysToRemove.add(jobId);
        }
      }

      for (final key in keysToRemove) {
        _processedHits.remove(key);
        _completedJobs.remove(key);
      }

      if (keysToRemove.isNotEmpty) {}
    } catch (e) {}
  }

  @override
  void dispose() {
    _processedHits.clear();
    _completedJobs.clear();
    _runnerProxyStates.clear();
    super.dispose();
  }
}
