// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_assignment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProxyAssignmentRequestImpl _$$ProxyAssignmentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ProxyAssignmentRequestImpl(
      jobId: json['jobId'] as String,
      botId: json['botId'] as String,
      allowConcurrent: json['allowConcurrent'] as bool,
      maxUses: (json['maxUses'] as num).toInt(),
      neverBan: json['neverBan'] as bool,
      preferredTypes: (json['preferredTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$ProxyTypeEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$$ProxyAssignmentRequestImplToJson(
        _$ProxyAssignmentRequestImpl instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'botId': instance.botId,
      'allowConcurrent': instance.allowConcurrent,
      'maxUses': instance.maxUses,
      'neverBan': instance.neverBan,
      'preferredTypes':
          instance.preferredTypes?.map((e) => _$ProxyTypeEnumMap[e]!).toList(),
    };

const _$ProxyTypeEnumMap = {
  ProxyType.http: 'http',
  ProxyType.https: 'https',
  ProxyType.socks4: 'socks4',
  ProxyType.socks5: 'socks5',
};

_$ProxyAssignmentResponseImpl _$$ProxyAssignmentResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ProxyAssignmentResponseImpl(
      success: json['success'] as bool,
      proxy: json['proxy'] == null
          ? null
          : EnhancedProxyModel.fromJson(json['proxy'] as Map<String, dynamic>),
      error: json['error'] as String?,
      failureReason: $enumDecodeNullable(
          _$ProxyAssignmentFailureReasonEnumMap, json['failureReason']),
    );

Map<String, dynamic> _$$ProxyAssignmentResponseImplToJson(
        _$ProxyAssignmentResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'proxy': instance.proxy,
      'error': instance.error,
      'failureReason':
          _$ProxyAssignmentFailureReasonEnumMap[instance.failureReason],
    };

const _$ProxyAssignmentFailureReasonEnumMap = {
  ProxyAssignmentFailureReason.noProxiesAvailable: 'noProxiesAvailable',
  ProxyAssignmentFailureReason.allProxiesBanned: 'allProxiesBanned',
  ProxyAssignmentFailureReason.reloadRequired: 'reloadRequired',
  ProxyAssignmentFailureReason.maxUsesExceeded: 'maxUsesExceeded',
};
