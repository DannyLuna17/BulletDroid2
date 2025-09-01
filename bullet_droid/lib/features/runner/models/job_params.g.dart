// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobParamsImpl _$$JobParamsImplFromJson(Map<String, dynamic> json) =>
    _$JobParamsImpl(
      configId: json['configId'] as String,
      configPath: json['configPath'] as String,
      dataLines:
          (json['dataLines'] as List<dynamic>).map((e) => e as String).toList(),
      startIndex: (json['startIndex'] as num?)?.toInt() ?? 0,
      threads: (json['threads'] as num?)?.toInt() ?? 1,
      timeout: (json['timeout'] as num?)?.toInt() ?? 60,
      proxies: (json['proxies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      useProxies: json['useProxies'] as bool? ?? true,
      proxyRetryCount: (json['proxyRetryCount'] as num?)?.toInt() ?? 3,
      customInputs: json['customInputs'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$JobParamsImplToJson(_$JobParamsImpl instance) =>
    <String, dynamic>{
      'configId': instance.configId,
      'configPath': instance.configPath,
      'dataLines': instance.dataLines,
      'startIndex': instance.startIndex,
      'threads': instance.threads,
      'timeout': instance.timeout,
      'proxies': instance.proxies,
      'useProxies': instance.useProxies,
      'proxyRetryCount': instance.proxyRetryCount,
      'customInputs': instance.customInputs,
    };
