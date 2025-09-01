// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runner_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RunnerInstanceImpl _$$RunnerInstanceImplFromJson(Map<String, dynamic> json) =>
    _$RunnerInstanceImpl(
      runnerId: json['runnerId'] as String,
      jobId: json['jobId'] as String?,
      isRunning: json['isRunning'] as bool? ?? false,
      isInitialized: json['isInitialized'] as bool? ?? false,
      selectedConfigId: json['selectedConfigId'] as String?,
      selectedWordlistId: json['selectedWordlistId'] as String?,
      selectedProxies: json['selectedProxies'] as String? ?? 'Default',
      useProxies: json['useProxies'] as bool? ?? false,
      startCount: (json['startCount'] as num?)?.toInt() ?? 1,
      botsCount: (json['botsCount'] as num?)?.toInt() ?? 1,
      botResults: (json['botResults'] as List<dynamic>?)
              ?.map(
                  (e) => BotExecutionResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      proxyStats: (json['proxyStats'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {'untested': 0, 'good': 0, 'bad': 0, 'banned': 0},
      dataStats: (json['dataStats'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {
            'pending': 0,
            'success': 0,
            'custom': 0,
            'failed': 0,
            'tocheck': 0,
            'retry': 0
          },
      currentCpm: (json['currentCpm'] as num?)?.toInt() ?? 0,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      error: json['error'] as String?,
      currentJobProgress: json['currentJobProgress'] == null
          ? null
          : JobProgress.fromJson(
              json['currentJobProgress'] as Map<String, dynamic>),
      finalJobProgress: json['finalJobProgress'] == null
          ? null
          : JobProgress.fromJson(
              json['finalJobProgress'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RunnerInstanceImplToJson(
        _$RunnerInstanceImpl instance) =>
    <String, dynamic>{
      'runnerId': instance.runnerId,
      'jobId': instance.jobId,
      'isRunning': instance.isRunning,
      'isInitialized': instance.isInitialized,
      'selectedConfigId': instance.selectedConfigId,
      'selectedWordlistId': instance.selectedWordlistId,
      'selectedProxies': instance.selectedProxies,
      'useProxies': instance.useProxies,
      'startCount': instance.startCount,
      'botsCount': instance.botsCount,
      'botResults': instance.botResults,
      'proxyStats': instance.proxyStats,
      'dataStats': instance.dataStats,
      'currentCpm': instance.currentCpm,
      'lastActivity': instance.lastActivity.toIso8601String(),
      'error': instance.error,
      'currentJobProgress': instance.currentJobProgress,
      'finalJobProgress': instance.finalJobProgress,
    };
