// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_custom_input_values.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigCustomInputValuesAdapter
    extends TypeAdapter<ConfigCustomInputValues> {
  @override
  final int typeId = 3;

  @override
  ConfigCustomInputValues read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigCustomInputValues(
      values: (fields[0] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as Map).cast<String, String>())),
    );
  }

  @override
  void write(BinaryWriter writer, ConfigCustomInputValues obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.values);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigCustomInputValuesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
