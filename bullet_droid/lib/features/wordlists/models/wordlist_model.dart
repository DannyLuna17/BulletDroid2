import 'package:freezed_annotation/freezed_annotation.dart';

part 'wordlist_model.freezed.dart';
part 'wordlist_model.g.dart';

@freezed
class WordlistModel with _$WordlistModel {
  const factory WordlistModel({
    required String id,
    required String name,
    required String path,
    required String type,
    required int totalLines,
    String? purpose,
    DateTime? createdAt,
    DateTime? lastUsed,
    @Default({}) Map<String, dynamic> metadata,
  }) = _WordlistModel;

  factory WordlistModel.fromJson(Map<String, dynamic> json) =>
      _$WordlistModelFromJson(json);
}
