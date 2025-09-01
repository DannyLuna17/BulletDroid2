// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_proxy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnhancedProxyModelImpl _$$EnhancedProxyModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EnhancedProxyModelImpl(
      id: json['id'] as String,
      address: json['address'] as String,
      port: (json['port'] as num).toInt(),
      type: $enumDecode(_$ProxyTypeEnumMap, json['type']),
      status: $enumDecode(_$ProxyStatusEnumMap, json['status']),
      username: json['username'] as String?,
      password: json['password'] as String?,
      lastChecked: json['lastChecked'] == null
          ? null
          : DateTime.parse(json['lastChecked'] as String),
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      uses: (json['uses'] as num?)?.toInt() ?? 0,
      hooked: (json['hooked'] as num?)?.toInt() ?? 0,
      successCount: (json['successCount'] as num?)?.toInt() ?? 0,
      failureCount: (json['failureCount'] as num?)?.toInt() ?? 0,
      responseTime: (json['responseTime'] as num?)?.toInt() ?? 0,
      country: json['country'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$EnhancedProxyModelImplToJson(
        _$EnhancedProxyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'port': instance.port,
      'type': _$ProxyTypeEnumMap[instance.type]!,
      'status': _$ProxyStatusEnumMap[instance.status]!,
      'username': instance.username,
      'password': instance.password,
      'lastChecked': instance.lastChecked?.toIso8601String(),
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'uses': instance.uses,
      'hooked': instance.hooked,
      'successCount': instance.successCount,
      'failureCount': instance.failureCount,
      'responseTime': instance.responseTime,
      'country': instance.country,
      'metadata': instance.metadata,
    };

const _$ProxyTypeEnumMap = {
  ProxyType.http: 'http',
  ProxyType.https: 'https',
  ProxyType.socks4: 'socks4',
  ProxyType.socks5: 'socks5',
};

const _$ProxyStatusEnumMap = {
  ProxyStatus.available: 'available',
  ProxyStatus.busy: 'busy',
  ProxyStatus.banned: 'banned',
  ProxyStatus.bad: 'bad',
  ProxyStatus.untested: 'untested',
  ProxyStatus.testing: 'testing',
};
