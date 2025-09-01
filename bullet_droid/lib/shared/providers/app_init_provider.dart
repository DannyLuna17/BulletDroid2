import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/shared/providers/hive_provider.dart';
import 'package:bullet_droid/shared/providers/custom_input_provider.dart';
import 'package:bullet_droid/core/utils/logging.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/wordlists/providers/wordlists_provider.dart';
import 'package:bullet_droid/features/dashboard/providers/dashboard_provider.dart';
import 'package:bullet_droid/features/runner/providers/runner_provider.dart';

// Ensures storage/services/providers are ready so the UI can start in a consistent state.
final appDataInitProvider = FutureProvider<void>((ref) async {
  // Wait for Hive to be initialized first
  await ref.watch(hiveInitProvider.future);

  // Load all data in parallel
  await Future.wait([
    _initCustomInputProvider(ref),
    _loadConfigs(ref),
    _loadWordlists(ref),
    _loadDashboardExecutions(ref),
    _initRunnerProvider(ref),
  ]);
});

Future<void> _loadConfigs(Ref ref) async {
  try {
    ref.read(configsProvider);
  } catch (e) {
    Log.w('Error loading configs: $e');
  }
}

Future<void> _loadWordlists(Ref ref) async {
  try {
    ref.read(wordlistsProvider);
  } catch (e) {
    Log.w('Error loading wordlists: $e');
  }
}

Future<void> _loadDashboardExecutions(Ref ref) async {
  try {
    ref.read(configExecutionsProvider);
  } catch (e) {
    Log.w('Error loading dashboard executions: $e');
  }
}

Future<void> _initCustomInputProvider(Ref ref) async {
  try {
    final notifier = ref.read(customInputProvider.notifier);
    await notifier.ensureInitialized();
  } catch (e) {
    Log.w('Error initializing custom input provider: $e');
  }
}

Future<void> _initRunnerProvider(Ref ref) async {
  try {
    ref.read(multiRunnerProvider);
  } catch (e) {
    Log.w('Error initializing runner provider: $e');
  }
}
