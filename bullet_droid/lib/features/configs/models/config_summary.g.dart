// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConfigSummaryImpl _$$ConfigSummaryImplFromJson(Map<String, dynamic> json) =>
    _$ConfigSummaryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      author: json['author'] as String,
      filePath: json['filePath'] as String,
      hits: (json['hits'] as num?)?.toInt() ?? 0,
      fails: (json['fails'] as num?)?.toInt() ?? 0,
      retries: (json['retries'] as num?)?.toInt() ?? 0,
      totalRuns: (json['totalRuns'] as num?)?.toInt() ?? 0,
      lastChecked: json['lastChecked'] == null
          ? null
          : DateTime.parse(json['lastChecked'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ConfigSummaryImplToJson(_$ConfigSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author': instance.author,
      'filePath': instance.filePath,
      'hits': instance.hits,
      'fails': instance.fails,
      'retries': instance.retries,
      'totalRuns': instance.totalRuns,
      'lastChecked': instance.lastChecked?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'tags': instance.tags,
      'description': instance.description,
      'metadata': instance.metadata,
    };
