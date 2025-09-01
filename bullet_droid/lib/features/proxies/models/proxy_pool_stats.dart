import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bullet_droid/features/proxies/models/enhanced_proxy_model.dart';

part 'proxy_pool_stats.freezed.dart';
part 'proxy_pool_stats.g.dart';

@freezed
class ProxyPoolStats with _$ProxyPoolStats {
  const factory ProxyPoolStats({
    @Default(0) int total,
    @Default(0) int available,
    @Default(0) int busy,
    @Default(0) int banned,
    @Default(0) int bad,
    @Default(0) int untested,
    @Default(0) int alive,
    Map<ProxyType, int>? byType,
    Map<String, int>? byCountry,
  }) = _ProxyPoolStats;

  factory ProxyPoolStats.fromJson(Map<String, dynamic> json) =>
      _$ProxyPoolStatsFromJson(json);
}

// Extension methods for calculations
extension ProxyPoolStatsExtensions on ProxyPoolStats {
  /// Calculate alive count
  int get calculatedAlive => available + busy;

  /// Get percentage of working proxies
  double get workingPercentage {
    if (total == 0) return 0.0;
    return (alive / total) * 100;
  }

  /// Get percentage of banned proxies
  double get bannedPercentage {
    if (total == 0) return 0.0;
    return (banned / total) * 100;
  }

  /// Get percentage of bad proxies
  double get badPercentage {
    if (total == 0) return 0.0;
    return (bad / total) * 100;
  }

  /// Check if proxy pool is healthy
  bool get isHealthy => workingPercentage > 50.0;

  /// Create updated stats with corrected alive count
  ProxyPoolStats withCorrectedAlive() {
    return copyWith(alive: calculatedAlive);
  }
}
