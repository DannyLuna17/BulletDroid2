import 'package:freezed_annotation/freezed_annotation.dart';

part 'enhanced_proxy_model.freezed.dart';
part 'enhanced_proxy_model.g.dart';

@freezed
class EnhancedProxyModel with _$EnhancedProxyModel {
  const factory EnhancedProxyModel({
    required String id,
    required String address,
    required int port,
    required ProxyType type,
    required ProxyStatus status,
    String? username,
    String? password,
    DateTime? lastChecked,
    DateTime? lastUsed,
    @Default(0) int uses,
    @Default(0) int hooked,
    @Default(0) int successCount,
    @Default(0) int failureCount,
    @Default(0) int responseTime,
    String? country,
    @Default({}) Map<String, dynamic> metadata,
  }) = _EnhancedProxyModel;

  factory EnhancedProxyModel.fromJson(Map<String, dynamic> json) =>
      _$EnhancedProxyModelFromJson(json);
}

enum ProxyType { http, https, socks4, socks5 }

enum ProxyStatus { available, busy, banned, bad, untested, testing }

// Extension methods
extension EnhancedProxyModelExtensions on EnhancedProxyModel {
  /// Convert to string representation
  String get proxyString {
    if (username != null && password != null) {
      return '$username:$password@$address:$port';
    }
    return '$address:$port';
  }

  /// Check if proxy is alive (available or busy)
  bool get isAlive =>
      status == ProxyStatus.available || status == ProxyStatus.busy;

  /// Check if proxy can be assigned
  bool get canAssign => status == ProxyStatus.available;

  /// Create copy with updated status
  EnhancedProxyModel withStatus(ProxyStatus newStatus) {
    return copyWith(
      status: newStatus,
      lastUsed: newStatus == ProxyStatus.busy ? DateTime.now() : lastUsed,
    );
  }

  /// Create copy with incremented usage
  EnhancedProxyModel withIncrementedUsage() {
    return copyWith(uses: uses + 1, lastUsed: DateTime.now());
  }

  /// Create copy with updated response time
  EnhancedProxyModel withResponseTime(int responseTimeMs) {
    return copyWith(responseTime: responseTimeMs, lastChecked: DateTime.now());
  }
}
