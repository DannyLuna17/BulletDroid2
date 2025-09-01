import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bullet_droid/features/runner/models/job_progress.dart';

part 'runner_instance.freezed.dart';
part 'runner_instance.g.dart';

@freezed
class RunnerInstance with _$RunnerInstance {
  const factory RunnerInstance({
    required String runnerId,
    String? jobId,
    @Default(false) bool isRunning,
    @Default(false) bool isInitialized,

    // Runner parameters
    String? selectedConfigId,
    String? selectedWordlistId,
    @Default('Default') String selectedProxies,
    @Default(false) bool useProxies,
    @Default(1) int startCount,
    @Default(1) int botsCount,

    // Real-time execution data
    @Default([]) List<BotExecutionResult> botResults,
    @Default({'untested': 0, 'good': 0, 'bad': 0, 'banned': 0})
    Map<String, int> proxyStats,
    @Default({
      'pending': 0,
      'success': 0,
      'custom': 0,
      'failed': 0,
      'tocheck': 0,
      'retry': 0,
    })
    Map<String, int> dataStats,
    @Default(0) int currentCpm,

    // Lifecycle tracking
    required DateTime lastActivity,
    String? error,

    JobProgress? currentJobProgress,
    JobProgress? finalJobProgress,
  }) = _RunnerInstance;

  factory RunnerInstance.fromJson(Map<String, dynamic> json) =>
      _$RunnerInstanceFromJson(json);
}

extension RunnerInstanceExtension on RunnerInstance {
  bool get isFullyInitialized => isInitialized;

  bool get hasActiveJob => jobId != null && isRunning;

  RunnerInstance updateActivity() {
    return copyWith(lastActivity: DateTime.now());
  }

  RunnerInstance startJob(String newJobId) {
    return copyWith(
      jobId: newJobId,
      isRunning: true,
      error: null,
      botResults: [],
      proxyStats: const {'untested': 0, 'good': 0, 'bad': 0, 'banned': 0},
      dataStats: const {
        'pending': 0,
        'success': 0,
        'custom': 0,
        'failed': 0,
        'tocheck': 0,
        'retry': 0,
      },
      currentCpm: 0,
      lastActivity: DateTime.now(),
      currentJobProgress: null,
      finalJobProgress: null,
    );
  }

  RunnerInstance stopJob({JobProgress? finalProgress}) {
    return copyWith(
      isRunning: false,
      jobId: null,
      lastActivity: DateTime.now(),
      currentJobProgress: null,
      finalJobProgress: finalProgress,
    );
  }

  RunnerInstance updateProgress({
    List<BotExecutionResult>? botResults,
    Map<String, int>? proxyStats,
    Map<String, int>? dataStats,
    int? currentCpm,
  }) {
    return copyWith(
      botResults: botResults ?? this.botResults,
      proxyStats: proxyStats ?? this.proxyStats,
      dataStats: dataStats ?? this.dataStats,
      currentCpm: currentCpm ?? this.currentCpm,
      lastActivity: DateTime.now(),
    );
  }
}
