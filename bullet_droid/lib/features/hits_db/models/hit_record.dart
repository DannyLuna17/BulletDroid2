import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hit_record.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class HitRecord {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String data;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String configId;

  @HiveField(4)
  final String configName;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String wordlistId;

  @HiveField(7)
  final String wordlistName;

  @HiveField(8)
  final String? proxy;

  @HiveField(9)
  final Map<String, String> capturedData;

  @HiveField(10)
  final String jobId;

  const HitRecord({
    required this.id,
    required this.data,
    required this.type,
    required this.configId,
    required this.configName,
    required this.date,
    required this.wordlistId,
    required this.wordlistName,
    this.proxy,
    required this.capturedData,
    required this.jobId,
  });

  factory HitRecord.fromJson(Map<String, dynamic> json) =>
      _$HitRecordFromJson(json);
  Map<String, dynamic> toJson() => _$HitRecordToJson(this);

  @override
  String toString() {
    return 'HitRecord(id: $id, data: $data, type: $type, configName: $configName, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HitRecord &&
        other.id == id &&
        other.data == data &&
        other.type == type &&
        other.configId == configId &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        data.hashCode ^
        type.hashCode ^
        configId.hashCode ^
        date.hashCode;
  }

  /// Create a formatted string representation based on selected fields
  String toFormattedString({
    bool includeProxy = false,
    bool includeCapturedData = false,
    bool includeConfig = false,
    bool includeDate = false,
    bool includeWordlist = false,
  }) {
    final parts = <String>[data];

    if (includeProxy && proxy != null) {
      parts.add('proxy:$proxy');
    }

    if (includeCapturedData && capturedData.isNotEmpty) {
      final captureString = capturedData.entries
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      parts.add('captured:$captureString');
    }

    if (includeConfig) {
      parts.add('config:$configName');
    }

    if (includeDate) {
      parts.add('date:${date.toIso8601String()}');
    }

    if (includeWordlist) {
      parts.add('wordlist:$wordlistName');
    }

    return parts.join(' | ');
  }
}
