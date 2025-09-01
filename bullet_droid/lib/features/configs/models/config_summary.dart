import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_summary.freezed.dart';
part 'config_summary.g.dart';

@freezed
class ConfigSummary with _$ConfigSummary {
  const factory ConfigSummary({
    required String id,
    required String name,
    required String author,
    required String filePath,
    @Default(0) int hits,
    @Default(0) int fails,
    @Default(0) int retries,
    @Default(0) int totalRuns,
    DateTime? lastChecked,
    DateTime? createdAt,
    @Default([]) List<String> tags,
    String? description,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ConfigSummary;

  factory ConfigSummary.fromJson(Map<String, dynamic> json) =>
      _$ConfigSummaryFromJson(json);
}
