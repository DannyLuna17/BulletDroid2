// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ValidDataResultImpl _$$ValidDataResultImplFromJson(
        Map<String, dynamic> json) =>
    _$ValidDataResultImpl(
      data: json['data'] as String,
      status: $enumDecode(_$BotStatusEnumMap, json['status']),
      completionTime: DateTime.parse(json['completionTime'] as String),
      proxy: json['proxy'] as String?,
      captures: (json['captures'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      customStatus: json['customStatus'] as String?,
    );

Map<String, dynamic> _$$ValidDataResultImplToJson(
        _$ValidDataResultImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'status': _$BotStatusEnumMap[instance.status]!,
      'completionTime': instance.completionTime.toIso8601String(),
      'proxy': instance.proxy,
      'captures': instance.captures,
      'customStatus': instance.customStatus,
    };

const _$BotStatusEnumMap = {
  BotStatus.idle: 'idle',
  BotStatus.preparing: 'preparing',
  BotStatus.running: 'running',
  BotStatus.SUCCESS: 'SUCCESS',
  BotStatus.CUSTOM: 'CUSTOM',
  BotStatus.RETRY: 'RETRY',
  BotStatus.TOCHECK: 'TOCHECK',
  BotStatus.FAILED: 'FAILED',
};

_$JobProgressImpl _$$JobProgressImplFromJson(Map<String, dynamic> json) =>
    _$JobProgressImpl(
      jobId: json['jobId'] as String,
      runnerId: json['runnerId'] as String?,
      configId: json['configId'] as String,
      status: $enumDecode(_$JobStatusEnumMap, json['status']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      totalLines: (json['totalLines'] as num?)?.toInt() ?? 0,
      processedLines: (json['processedLines'] as num?)?.toInt() ?? 0,
      hits: (json['hits'] as List<dynamic>?)
              ?.map((e) => ValidDataResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fails: (json['fails'] as List<dynamic>?)
              ?.map((e) => ValidDataResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      customs: (json['customs'] as List<dynamic>?)
              ?.map((e) => ValidDataResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      toChecks: (json['toChecks'] as List<dynamic>?)
              ?.map((e) => ValidDataResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cpm: (json['cpm'] as num?)?.toInt() ?? 0,
      blockExecutions: (json['blockExecutions'] as List<dynamic>?)
              ?.map((e) => BlockExecution.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentBlock: json['currentBlock'] as String?,
      error: json['error'] as String?,
      results: json['results'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$JobProgressImplToJson(_$JobProgressImpl instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'runnerId': instance.runnerId,
      'configId': instance.configId,
      'status': _$JobStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'totalLines': instance.totalLines,
      'processedLines': instance.processedLines,
      'hits': instance.hits,
      'fails': instance.fails,
      'customs': instance.customs,
      'toChecks': instance.toChecks,
      'cpm': instance.cpm,
      'blockExecutions': instance.blockExecutions,
      'currentBlock': instance.currentBlock,
      'error': instance.error,
      'results': instance.results,
    };

const _$JobStatusEnumMap = {
  JobStatus.idle: 'idle',
  JobStatus.preparing: 'preparing',
  JobStatus.running: 'running',
  JobStatus.paused: 'paused',
  JobStatus.completed: 'completed',
  JobStatus.failed: 'failed',
  JobStatus.cancelled: 'cancelled',
};

_$BlockExecutionImpl _$$BlockExecutionImplFromJson(Map<String, dynamic> json) =>
    _$BlockExecutionImpl(
      blockName: json['blockName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      success: json['success'] as bool,
      error: json['error'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BlockExecutionImplToJson(
        _$BlockExecutionImpl instance) =>
    <String, dynamic>{
      'blockName': instance.blockName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'success': instance.success,
      'error': instance.error,
      'data': instance.data,
    };

_$BotExecutionResultImpl _$$BotExecutionResultImplFromJson(
        Map<String, dynamic> json) =>
    _$BotExecutionResultImpl(
      botId: (json['botId'] as num).toInt(),
      data: json['data'] as String,
      status: $enumDecode(_$BotStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      proxy: json['proxy'] as String?,
      elapsed: json['elapsed'] == null
          ? null
          : Duration(microseconds: (json['elapsed'] as num).toInt()),
      captures: (json['captures'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      errorMessage: json['errorMessage'] as String?,
      retryCount: (json['retryCount'] as num?)?.toInt(),
      customStatus: json['customStatus'] as String?,
      currentStatus: json['currentStatus'] as String?,
      currentDataIndex: (json['currentDataIndex'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$BotExecutionResultImplToJson(
        _$BotExecutionResultImpl instance) =>
    <String, dynamic>{
      'botId': instance.botId,
      'data': instance.data,
      'status': _$BotStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'proxy': instance.proxy,
      'elapsed': instance.elapsed?.inMicroseconds,
      'captures': instance.captures,
      'errorMessage': instance.errorMessage,
      'retryCount': instance.retryCount,
      'customStatus': instance.customStatus,
      'currentStatus': instance.currentStatus,
      'currentDataIndex': instance.currentDataIndex,
    };

_$ProxyStatusImpl _$$ProxyStatusImplFromJson(Map<String, dynamic> json) =>
    _$ProxyStatusImpl(
      proxy: json['proxy'] as String,
      state: $enumDecode(_$ProxyStateEnumMap, json['state']),
      usageCount: (json['usageCount'] as num).toInt(),
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
    );

Map<String, dynamic> _$$ProxyStatusImplToJson(_$ProxyStatusImpl instance) =>
    <String, dynamic>{
      'proxy': instance.proxy,
      'state': _$ProxyStateEnumMap[instance.state]!,
      'usageCount': instance.usageCount,
      'lastUsed': instance.lastUsed?.toIso8601String(),
    };

const _$ProxyStateEnumMap = {
  ProxyState.untested: 'untested',
  ProxyState.good: 'good',
  ProxyState.bad: 'bad',
  ProxyState.banned: 'banned',
};

_$BotResultUpdateImpl _$$BotResultUpdateImplFromJson(
        Map<String, dynamic> json) =>
    _$BotResultUpdateImpl(
      jobId: json['jobId'] as String,
      runnerId: json['runnerId'] as String?,
      botResults: (json['botResults'] as List<dynamic>)
          .map((e) => BotExecutionResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BotResultUpdateImplToJson(
        _$BotResultUpdateImpl instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'runnerId': instance.runnerId,
      'botResults': instance.botResults,
    };

_$ProxyUpdateImpl _$$ProxyUpdateImplFromJson(Map<String, dynamic> json) =>
    _$ProxyUpdateImpl(
      jobId: json['jobId'] as String,
      runnerId: json['runnerId'] as String?,
      proxies: (json['proxies'] as List<dynamic>)
          .map((e) => ProxyStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProxyUpdateImplToJson(_$ProxyUpdateImpl instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'runnerId': instance.runnerId,
      'proxies': instance.proxies,
    };
