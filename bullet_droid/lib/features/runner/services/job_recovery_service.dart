import 'dart:async';

import 'package:bullet_droid/features/runner/models/runner_instance.dart';
import 'package:bullet_droid/features/runner/models/job_progress.dart';
import 'package:bullet_droid/features/runner/services/isolate_pool_service.dart';

class JobRecoveryService {
  static const int maxConcurrentRunners = 10;
  static const Duration runnerInactivityTimeout = Duration(hours: 24);

  // In-memory storage for session persistence
  final Map<String, RunnerInstance> _runnerInstances = {};
  final Map<String, String> _jobToRunnerMapping = {};

  // Separate storage for final job progress to prevent loss
  final Map<String, JobProgress> _finalJobProgress = {};

  // Singleton instance
  static final JobRecoveryService _instance = JobRecoveryService._internal();
  JobRecoveryService._internal();
  factory JobRecoveryService() => _instance;

  /// Get all active runner instances
  Map<String, RunnerInstance> get allRunners {
    final result = <String, RunnerInstance>{};
    for (final entry in _runnerInstances.entries) {
      final runnerId = entry.key;
      final runner = entry.value;
      final storedFinalProgress = _finalJobProgress[runnerId];
      result[runnerId] = runner.copyWith(finalJobProgress: storedFinalProgress);
    }
    return Map.unmodifiable(result);
  }

  /// Read-only snapshot of raw runner instances
  Map<String, RunnerInstance> get runnersSnapshot =>
      Map.unmodifiable(_runnerInstances);

  /// Get a specific runner instance
  RunnerInstance? getRunner(String runnerId) {
    final runner = _runnerInstances[runnerId];
    if (runner == null) {
      return null;
    }

    // Always ensure final progress is attached from separate storage
    final storedFinalProgress = _finalJobProgress[runnerId];

    final runnerWithFinalProgress = runner.copyWith(
      finalJobProgress: storedFinalProgress,
    );

    return runnerWithFinalProgress;
  }

  /// Create or update a runner instance
  void updateRunner(String runnerId, RunnerInstance instance) {
    if (instance.finalJobProgress != null) {
      _finalJobProgress[runnerId] = instance.finalJobProgress!;
    }

    final finalProgressToUse = _finalJobProgress[runnerId];

    final updatedInstance = instance.copyWith(
      lastActivity: DateTime.now(),
      finalJobProgress: finalProgressToUse,
    );
    _runnerInstances[runnerId] = updatedInstance;

    // Update job mapping if runner has active job
    if (instance.jobId != null) {
      _jobToRunnerMapping[instance.jobId!] = runnerId;
    }
  }

  /// Remove a runner instance
  void removeRunner(String runnerId) {
    final instance = _runnerInstances[runnerId];
    if (instance?.jobId != null) {
      _jobToRunnerMapping.remove(instance!.jobId);
    }
    _runnerInstances.remove(runnerId);
    _finalJobProgress.remove(runnerId);
  }

  /// Clear final job progress for a runner
  void clearFinalJobProgress(String runnerId) {
    _finalJobProgress.remove(runnerId);
  }

  /// Get runner ID for a given job ID
  String? getRunnerForJob(String jobId) {
    return _jobToRunnerMapping[jobId];
  }

  /// Create a new runner instance
  RunnerInstance createRunner(String runnerId) {
    final instance = RunnerInstance(
      runnerId: runnerId,
      lastActivity: DateTime.now(),
      isInitialized: true,
    );
    _runnerInstances[runnerId] = instance;
    return instance;
  }

  /// Check if a runner can start a new job
  bool canStartJob(String runnerId) {
    final instance = _runnerInstances[runnerId];
    if (instance == null) return true; // New runner

    return !instance.hasActiveJob;
  }

  /// Get count of active jobs
  int get activeJobCount {
    return _runnerInstances.values.where((r) => r.hasActiveJob).length;
  }

  /// Check if system can handle more concurrent jobs
  bool get canAcceptNewJob {
    return activeJobCount < maxConcurrentRunners;
  }

  /// Recover runner job state from isolate pool
  Future<RunnerInstance?> recoverRunnerJob(
    String runnerId,
    IsolatePoolService isolatePool,
  ) async {
    final instance = getRunner(runnerId);
    if (instance?.jobId == null) {
      return instance;
    }

    try {
      // Check if job is still active in isolate pool
      final activeJobs = isolatePool.getActiveJobs();
      final isJobActive = activeJobs.contains(instance!.jobId);

      if (isJobActive) {
        return instance.copyWith(lastActivity: DateTime.now());
      } else {
        if (!instance.isRunning && instance.finalJobProgress != null) {
          return instance.copyWith(lastActivity: DateTime.now());
        } else {
          final stoppedInstance = instance.stopJob();
          updateRunner(runnerId, stoppedInstance);
          _jobToRunnerMapping.remove(instance.jobId);
          return getRunner(runnerId);
        }
      }
    } catch (e) {
      return instance;
    }
  }

  /// Clean up inactive runners
  void cleanupInactiveRunners() {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _runnerInstances.entries) {
      final runnerId = entry.key;
      final instance = entry.value;

      if (!instance.hasActiveJob &&
          now.difference(instance.lastActivity) > runnerInactivityTimeout) {
        toRemove.add(runnerId);
      }
    }

    for (final runnerId in toRemove) {
      removeRunner(runnerId);
    }
  }

  /// Associate job with runner for tracking
  void associateJobWithRunner(String jobId, String runnerId) {
    _jobToRunnerMapping[jobId] = runnerId;

    final instance = _runnerInstances[runnerId];
    if (instance != null) {
      _runnerInstances[runnerId] = instance.startJob(jobId);
    }
  }

  /// Handle job completion cleanup
  void onJobCompleted(String jobId) {
    final runnerId = _jobToRunnerMapping[jobId];
    if (runnerId != null) {
      final instance = _runnerInstances[runnerId];
      if (instance != null) {
        _runnerInstances[runnerId] = instance.stopJob();
      }
      _jobToRunnerMapping.remove(jobId);
    }
  }

  /// Get list of all active job IDs
  List<String> get activeJobIds {
    return _runnerInstances.values
        .where((r) => r.jobId != null)
        .map((r) => r.jobId!)
        .toList();
  }

  /// Clear all runner data
  void clear() {
    _runnerInstances.clear();
    _jobToRunnerMapping.clear();
  }
}
