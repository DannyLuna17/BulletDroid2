import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid/core/router/navigation_service.dart';

import 'package:bullet_droid/features/home/presentation/home_shell.dart';
import 'package:bullet_droid/features/dashboard/presentation/dashboard_screen.dart';
import 'package:bullet_droid/features/configs/presentation/configs_screen.dart';
import 'package:bullet_droid/features/configs/presentation/config_details_screen.dart';
import 'package:bullet_droid/features/runner/presentation/runner_screen.dart';
import 'package:bullet_droid/features/runner/presentation/runner_route_params.dart';
import 'package:bullet_droid/core/utils/logging.dart';
import 'package:bullet_droid/features/proxies/presentation/working_proxies_screen.dart';
import 'package:bullet_droid/features/settings/presentation/settings_screen.dart';
import 'package:bullet_droid/features/settings/presentation/hits_db_screen.dart';
import 'package:bullet_droid/features/settings/presentation/license_page.dart';
import 'package:bullet_droid/features/wordlists/presentation/wordlists_screen.dart';
import 'package:bullet_droid/features/wordlists/presentation/custom_wordlist_types_screen.dart';

/// App-wide router configured with a global navigator key.
/// Route names and paths are defined by [AppRoute] and [AppPath] enums below
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    initialLocation: AppPath.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppPath.dashboard,
            name: AppRoute.dashboard,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppPath.configs,
            name: AppRoute.configs,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ConfigsScreen(),
            ),
          ),
          GoRoute(
            path: AppPath.runner,
            name: AppRoute.runner,
            pageBuilder: (context, state) {
              final params = RunnerRouteParams.fromState(state);
              if (params.source == RunnerSource.unknown) {
                Log.w(
                  'Runner route launched with unknown source. This may indicate a malformed link.',
                );
                assert(
                  false,
                  'Runner route launched with unknown source. This may indicate a malformed link.',
                );
              }
              return NoTransitionPage(
                key: state.pageKey,
                child: RunnerScreen(
                  placeholderId: params.placeholderId,
                  configId: params.configId,
                  source: params.source == RunnerSource.unknown
                      ? null
                      : runnerSourceToString(params.source),
                ),
              );
            },
          ),
          GoRoute(
            path: AppPath.proxies,
            name: AppRoute.proxies,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WorkingProxiesScreen(),
            ),
          ),
          GoRoute(
            path: AppPath.wordlists,
            name: AppRoute.wordlists,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WordlistsScreen(),
            ),
          ),
          GoRoute(
            path: AppPath.settings,
            name: AppRoute.settings,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: AppPath.customWordlistTypes,
            name: AppRoute.customWordlistTypes,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CustomWordlistTypesScreen(),
            ),
          ),
          GoRoute(
            path: AppPath.hitsDb,
            name: AppRoute.hitsDb,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HitsDbScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppPath.configDetails,
        name: AppRoute.configDetails,
        builder: (context, state) {
          final configId = state.pathParameters['id']!;
          return ConfigDetailsScreen(configId: configId);
        },
      ),
      GoRoute(
        path: AppPath.licenses,
        name: AppRoute.licenses,
        builder: (context, state) => const BulletDroidLicensePage(),
      ),
    ],
  );
});

/// Central route name definitions
class AppRoute {
  static const String dashboard = 'dashboard';
  static const String configs = 'configs';
  static const String runner = 'runner';
  static const String proxies = 'proxies';
  static const String wordlists = 'wordlists';
  static const String settings = 'settings';
  static const String customWordlistTypes = 'custom-wordlist-types';
  static const String hitsDb = 'hits-db';
  static const String configDetails = 'config-details';
  static const String licenses = 'licenses';
}

/// Central route path definitions
class AppPath {
  static const String dashboard = '/dashboard';
  static const String configs = '/configs';
  static const String runner = '/runner';
  static const String proxies = '/proxies';
  static const String wordlists = '/wordlists';
  static const String settings = '/settings';
  static const String customWordlistTypes = '/custom-wordlist-types';
  static const String hitsDb = '/hits-db';
  static const String configDetails = '/configs/:id';
  static const String licenses = '/licenses';
}
