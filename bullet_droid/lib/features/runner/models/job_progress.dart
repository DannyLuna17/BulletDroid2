import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_progress.freezed.dart';
part 'job_progress.g.dart';

@freezed
class ValidDataResult with _$ValidDataResult {
  const factory ValidDataResult({
    required String data,
    required BotStatus status,
    required DateTime completionTime,
    String? proxy,
    Map<String, String>? captures,
    String? customStatus,
  }) = _ValidDataResult;

  factory ValidDataResult.fromJson(Map<String, dynamic> json) =>
      _$ValidDataResultFromJson(json);
}

@freezed
class JobProgress with _$JobProgress {
  const factory JobProgress({
    required String jobId,
    String? runnerId,
    required String configId,
    required JobStatus status,
    required DateTime startTime,
    DateTime? endTime,
    @Default(0) int totalLines,
    @Default(0) int processedLines,
    @Default([]) List<ValidDataResult> hits,
    @Default([]) List<ValidDataResult> fails,
    @Default([]) List<ValidDataResult> customs,
    @Default([]) List<ValidDataResult> toChecks,
    @Default(0) int cpm,
    @Default([]) List<BlockExecution> blockExecutions,
    String? currentBlock,
    String? error,
    @Default({}) Map<String, dynamic> results,
  }) = _JobProgress;

  factory JobProgress.fromJson(Map<String, dynamic> json) =>
      _$JobProgressFromJson(json);
}

extension JobProgressExtension on JobProgress {
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'runnerId': runnerId,
      'configId': configId,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalLines': totalLines,
      'processedLines': processedLines,
      'hits': hits.map((e) => e.toJson()).toList(),
      'fails': fails.map((e) => e.toJson()).toList(),
      'customs': customs.map((e) => e.toJson()).toList(),
      'toChecks': toChecks.map((e) => e.toJson()).toList(),
      'cpm': cpm,
      'blockExecutions': blockExecutions.map((e) => e.toJson()).toList(),
      'currentBlock': currentBlock,
      'error': error,
      'results': results,
    };
  }
}

@freezed
class BlockExecution with _$BlockExecution {
  const factory BlockExecution({
    required String blockName,
    required DateTime startTime,
    DateTime? endTime,
    required bool success,
    String? error,
    Map<String, dynamic>? data,
  }) = _BlockExecution;

  factory BlockExecution.fromJson(Map<String, dynamic> json) =>
      _$BlockExecutionFromJson(json);
}

@freezed
class BotExecutionResult with _$BotExecutionResult {
  const factory BotExecutionResult({
    required int botId,
    required String data,
    required BotStatus status,
    required DateTime timestamp,
    String? proxy,
    Duration? elapsed,
    Map<String, String>? captures,
    String? errorMessage,
    int? retryCount,
    String? customStatus,
    String? currentStatus,
    int? currentDataIndex,
  }) = _BotExecutionResult;

  factory BotExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$BotExecutionResultFromJson(json);
}

extension BotExecutionResultExtension on BotExecutionResult {
  String get statusString {
    if (currentStatus != null && currentStatus!.isNotEmpty) {
      return currentStatus!;
    }

    final baseStatus = status == BotStatus.CUSTOM && customStatus != null
        ? customStatus!
        : status.name;

    if (currentDataIndex != null) {
      return '$baseStatus (Line ${currentDataIndex! + 1})';
    }

    return baseStatus;
  }
}

@freezed
class ProxyStatus with _$ProxyStatus {
  const factory ProxyStatus({
    required String proxy,
    required ProxyState state,
    required int usageCount,
    DateTime? lastUsed,
  }) = _ProxyStatus;

  factory ProxyStatus.fromJson(Map<String, dynamic> json) =>
      _$ProxyStatusFromJson(json);
}

@freezed
class BotResultUpdate with _$BotResultUpdate {
  const factory BotResultUpdate({
    required String jobId,
    String? runnerId,
    required List<BotExecutionResult> botResults,
  }) = _BotResultUpdate;

  factory BotResultUpdate.fromJson(Map<String, dynamic> json) =>
      _$BotResultUpdateFromJson(json);
}

@freezed
class ProxyUpdate with _$ProxyUpdate {
  const factory ProxyUpdate({
    required String jobId,
    String? runnerId,
    required List<ProxyStatus> proxies,
  }) = _ProxyUpdate;

  factory ProxyUpdate.fromJson(Map<String, dynamic> json) =>
      _$ProxyUpdateFromJson(json);
}

enum ProxyState { untested, good, bad, banned }

enum BotStatus {
  idle,
  preparing,
  running,
  SUCCESS,
  CUSTOM,
  RETRY,
  TOCHECK,
  FAILED,
}

enum JobStatus {
  idle,
  preparing,
  running,
  paused,
  completed,
  failed,
  cancelled,
}
