// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_pool_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProxyPoolStatsImpl _$$ProxyPoolStatsImplFromJson(Map<String, dynamic> json) =>
    _$ProxyPoolStatsImpl(
      total: (json['total'] as num?)?.toInt() ?? 0,
      available: (json['available'] as num?)?.toInt() ?? 0,
      busy: (json['busy'] as num?)?.toInt() ?? 0,
      banned: (json['banned'] as num?)?.toInt() ?? 0,
      bad: (json['bad'] as num?)?.toInt() ?? 0,
      untested: (json['untested'] as num?)?.toInt() ?? 0,
      alive: (json['alive'] as num?)?.toInt() ?? 0,
      byType: (json['byType'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry($enumDecode(_$ProxyTypeEnumMap, k), (e as num).toInt()),
      ),
      byCountry: (json['byCountry'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$$ProxyPoolStatsImplToJson(
        _$ProxyPoolStatsImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'available': instance.available,
      'busy': instance.busy,
      'banned': instance.banned,
      'bad': instance.bad,
      'untested': instance.untested,
      'alive': instance.alive,
      'byType':
          instance.byType?.map((k, e) => MapEntry(_$ProxyTypeEnumMap[k]!, e)),
      'byCountry': instance.byCountry,
    };

const _$ProxyTypeEnumMap = {
  ProxyType.http: 'http',
  ProxyType.https: 'https',
  ProxyType.socks4: 'socks4',
  ProxyType.socks5: 'socks5',
};
