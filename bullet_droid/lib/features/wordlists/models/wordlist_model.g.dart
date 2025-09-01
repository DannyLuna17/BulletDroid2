// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wordlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordlistModelImpl _$$WordlistModelImplFromJson(Map<String, dynamic> json) =>
    _$WordlistModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      totalLines: (json['totalLines'] as num).toInt(),
      purpose: json['purpose'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$WordlistModelImplToJson(_$WordlistModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'type': instance.type,
      'totalLines': instance.totalLines,
      'purpose': instance.purpose,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'metadata': instance.metadata,
    };
