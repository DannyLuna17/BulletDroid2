// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hit_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HitRecordAdapter extends TypeAdapter<HitRecord> {
  @override
  final int typeId = 5;

  @override
  HitRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HitRecord(
      id: fields[0] as String,
      data: fields[1] as String,
      type: fields[2] as String,
      configId: fields[3] as String,
      configName: fields[4] as String,
      date: fields[5] as DateTime,
      wordlistId: fields[6] as String,
      wordlistName: fields[7] as String,
      proxy: fields[8] as String?,
      capturedData: (fields[9] as Map).cast<String, String>(),
      jobId: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HitRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.configId)
      ..writeByte(4)
      ..write(obj.configName)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.wordlistId)
      ..writeByte(7)
      ..write(obj.wordlistName)
      ..writeByte(8)
      ..write(obj.proxy)
      ..writeByte(9)
      ..write(obj.capturedData)
      ..writeByte(10)
      ..write(obj.jobId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HitRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HitRecord _$HitRecordFromJson(Map<String, dynamic> json) => HitRecord(
      id: json['id'] as String,
      data: json['data'] as String,
      type: json['type'] as String,
      configId: json['configId'] as String,
      configName: json['configName'] as String,
      date: DateTime.parse(json['date'] as String),
      wordlistId: json['wordlistId'] as String,
      wordlistName: json['wordlistName'] as String,
      proxy: json['proxy'] as String?,
      capturedData: Map<String, String>.from(json['capturedData'] as Map),
      jobId: json['jobId'] as String,
    );

Map<String, dynamic> _$HitRecordToJson(HitRecord instance) => <String, dynamic>{
      'id': instance.id,
      'data': instance.data,
      'type': instance.type,
      'configId': instance.configId,
      'configName': instance.configName,
      'date': instance.date.toIso8601String(),
      'wordlistId': instance.wordlistId,
      'wordlistName': instance.wordlistName,
      'proxy': instance.proxy,
      'capturedData': instance.capturedData,
      'jobId': instance.jobId,
    };
