import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_params.freezed.dart';
part 'job_params.g.dart';

@freezed
class JobParams with _$JobParams {
  const factory JobParams({
    required String configId,
    required String configPath,
    required List<String> dataLines,
    @Default(0) int startIndex,
    @Default(1) int threads,
    @Default(60) int timeout,
    @Default([]) List<String> proxies,
    @Default(true) bool useProxies,
    @Default(3) int proxyRetryCount,
    Map<String, dynamic>? customInputs,
  }) = _JobParams;

  factory JobParams.fromJson(Map<String, dynamic> json) =>
      _$JobParamsFromJson(json);
}
