import 'package:go_router/go_router.dart';
import 'package:bullet_droid/core/utils/logging.dart';

/// Typed mapper for RunnerScreen route parameters
enum RunnerSource { placeholder, config, existing, dashboard, unknown }

RunnerSource parseRunnerSource(String? source) {
  switch (source) {
    case 'placeholder':
      return RunnerSource.placeholder;
    case 'config':
      return RunnerSource.config;
    case 'existing':
      return RunnerSource.existing;
    case 'dashboard':
      return RunnerSource.dashboard;
    default:
      return RunnerSource.unknown;
  }
}

/// Convert a RunnerSource to its string representation for routing/query params
String runnerSourceToString(RunnerSource s) {
  switch (s) {
    case RunnerSource.placeholder:
      return 'placeholder';
    case RunnerSource.config:
      return 'config';
    case RunnerSource.existing:
      return 'existing';
    case RunnerSource.dashboard:
      return 'dashboard';
    case RunnerSource.unknown:
      return 'unknown';
  }
}

class RunnerRouteParams {
  final String? placeholderId;
  final String? configId;
  final RunnerSource source;

  const RunnerRouteParams({
    this.placeholderId,
    this.configId,
    this.source = RunnerSource.unknown,
  });

  static RunnerRouteParams fromState(GoRouterState state) {
    final qp = state.uri.queryParameters;
    final parsed = parseRunnerSource(qp['source']);
    assert(
      qp['source'] == null || parsed != RunnerSource.unknown,
      'RunnerRouteParams: unknown source value: "${qp['source']}"',
    );
    if (qp['source'] != null && parsed == RunnerSource.unknown) {
      Log.w('RunnerRouteParams: unknown source value: "${qp['source']}"');
    }
    return RunnerRouteParams(
      placeholderId: qp['placeholderId'],
      configId: qp['configId'],
      source: parsed,
    );
  }

  static RunnerRouteParams fromRaw({
    String? placeholderId,
    String? configId,
    String? source,
  }) {
    final parsed = parseRunnerSource(source);
    assert(
      source == null || parsed != RunnerSource.unknown,
      'RunnerRouteParams: unknown source value: "$source"',
    );
    if (source != null && parsed == RunnerSource.unknown) {
      Log.w('RunnerRouteParams: unknown source value: "$source"');
    }
    return RunnerRouteParams(
      placeholderId: placeholderId,
      configId: configId,
      source: parsed,
    );
  }

  Map<String, String> toQueryParameters() {
    final map = <String, String>{};
    if (placeholderId != null) map['placeholderId'] = placeholderId!;
    if (configId != null) map['configId'] = configId!;
    if (source != RunnerSource.unknown) {
      map['source'] = runnerSourceToString(source);
    }
    return map;
  }
}
