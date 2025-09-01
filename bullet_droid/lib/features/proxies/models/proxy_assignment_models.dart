import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bullet_droid/features/proxies/models/enhanced_proxy_model.dart';

part 'proxy_assignment_models.freezed.dart';
part 'proxy_assignment_models.g.dart';

@freezed
class ProxyAssignmentRequest with _$ProxyAssignmentRequest {
  const factory ProxyAssignmentRequest({
    required String jobId,
    required String botId,
    required bool allowConcurrent,
    required int maxUses,
    required bool neverBan,
    List<ProxyType>? preferredTypes,
  }) = _ProxyAssignmentRequest;

  factory ProxyAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$ProxyAssignmentRequestFromJson(json);
}

@freezed
class ProxyAssignmentResponse with _$ProxyAssignmentResponse {
  const factory ProxyAssignmentResponse({
    required bool success,
    EnhancedProxyModel? proxy,
    String? error,
    ProxyAssignmentFailureReason? failureReason,
  }) = _ProxyAssignmentResponse;

  factory ProxyAssignmentResponse.fromJson(Map<String, dynamic> json) =>
      _$ProxyAssignmentResponseFromJson(json);
}

enum ProxyAssignmentFailureReason {
  noProxiesAvailable,
  allProxiesBanned,
  reloadRequired,
  maxUsesExceeded,
}

// Factory methods for common responses
extension ProxyAssignmentResponseFactory on ProxyAssignmentResponse {
  static ProxyAssignmentResponse success(EnhancedProxyModel proxy) {
    return ProxyAssignmentResponse(success: true, proxy: proxy);
  }

  static ProxyAssignmentResponse failure(
    ProxyAssignmentFailureReason reason,
    String error,
  ) {
    return ProxyAssignmentResponse(
      success: false,
      failureReason: reason,
      error: error,
    );
  }
}
