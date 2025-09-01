import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:math';

part 'proxy_model.freezed.dart';
part 'proxy_model.g.dart';

@freezed
class ProxyModel with _$ProxyModel {
  const factory ProxyModel({
    required String id,
    required String address,
    required int port,
    required ProxyType type,
    required ProxyStatus status,
    String? username,
    String? password,
    DateTime? lastChecked,
    DateTime? lastUsed,
    @Default(0) int successCount,
    @Default(0) int failureCount,
    @Default(0) int responseTime,
    String? country,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ProxyModel;

  factory ProxyModel.fromJson(Map<String, dynamic> json) =>
      _$ProxyModelFromJson(json);
}

enum ProxyType {
  http,
  // https,
  socks4,
  socks5,
}

enum ProxyStatus { alive, dead, untested, testing }

// Extension to parse proxy strings
extension ProxyParser on String {
  ProxyModel? parseProxy() {
    try {
      // Support formats:
      // ip:port
      // ip:port:username:password
      // protocol://ip:port
      // protocol://username:password@ip:port

      final parts = split(':');
      if (parts.length >= 2) {
        final address = parts[0];
        final port = int.tryParse(parts[1]);

        if (port != null) {
          // Generate unique ID using timestamp + random number to avoid collisions
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final random = Random().nextInt(999999);
          final uniqueId = '${timestamp}_$random';

          return ProxyModel(
            id: uniqueId,
            address: address,
            port: port,
            type: ProxyType.http,
            status: ProxyStatus.untested,
            username: parts.length > 2 ? parts[2] : null,
            password: parts.length > 3 ? parts[3] : null,
          );
        }
      }
    } catch (_) {}

    return null;
  }
}
