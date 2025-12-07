import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bullet_droid/features/hits_db/models/hit_record.dart';
import 'package:bullet_droid/shared/models/config_custom_input_values.dart';

// Initializes Hive and opens all application boxes.
final hiveInitProvider = FutureProvider<void>((ref) async {
  if (!kIsWeb) {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
  } else {
    await Hive.initFlutter();
  }

  // Register type adapters
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(ConfigCustomInputValuesAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(HitRecordAdapter());
  }

  // Open all required boxes
  await Future.wait([
    Hive.openBox('settings'),
    Hive.openBox('configMetadata'),
    Hive.openBox('proxyLists'),
    Hive.openBox('jobHistory'),
    Hive.openBox('wordlistMetadata'),
    Hive.openBox('customWordlistTypes'),
    Hive.openBox('dashboardExecutions'),
    Hive.openBox('hits'),
    Hive.openBox('hits_db_ui_state'),
    Hive.openBox<ConfigCustomInputValues>('custom_input_values'),
  ]);
});

// Box providers
// Provider for settings box
final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box('settings');
});

// Provider for config metadata box
final configMetadataBoxProvider = Provider<Box>((ref) {
  return Hive.box('configMetadata');
});

// Provider for proxy lists box
final proxyListsBoxProvider = Provider<Box>((ref) {
  return Hive.box('proxyLists');
});

// Provider for job history box
final jobHistoryBoxProvider = Provider<Box>((ref) {
  return Hive.box('jobHistory');
});

// Provider for wordlist metadata box
final wordlistMetadataBoxProvider = Provider<Box>((ref) {
  return Hive.box('wordlistMetadata');
});

// Provider for custom wordlist types box
final customWordlistTypesBoxProvider = Provider<Box>((ref) {
  return Hive.box('customWordlistTypes');
});

// Provider for dashboard executions box
final dashboardExecutionsBoxProvider = Provider<Box>((ref) {
  return Hive.box('dashboardExecutions');
});

// Provider for hits box
final hitsBoxProvider = Provider<Box>((ref) {
  return Hive.box('hits');
});

// Settings keys
class SettingsKeys {
  static const String defaultThreads = 'default_threads';
  static const String defaultTimeout = 'default_timeout';
  static const String autoSaveResults = 'auto_save_results';
  static const String proxyRetryCount = 'proxy_retry_count';
  static const String enableNotifications = 'enable_notifications';
}
