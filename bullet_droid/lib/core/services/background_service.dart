import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:bullet_droid/core/utils/logging.dart';

/// Android foreground-service manager for runner lifecycle.
/// Keep a persistent notification reflecting the number of
/// active runners, and expose a simple API to start/update/stop based on a count.
class BackgroundService {
  BackgroundService._();

  static bool _initialized = false;
  static bool _serviceRunning = false;
  static final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();
  static bool _permissionChecked = false;
  static bool _batteryPromptShown = false;
  static int _currentRunnerCount = 0;
  static DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _minUpdateIntervalMs = 500;

  /// Initialize foreground task configuration.
  static Future<void> initialize() async {
    if (_initialized) return;
    if (!Platform.isAndroid) {
      _initialized = true;
      return;
    }

    // Configure default notification and set up foreground service options
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'bulletdroid_runner',
          channelName: 'Runner',
          channelDescription: 'Shows active runners in background',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(15000),
          autoRunOnBoot: false,
          autoRunOnMyPackageReplaced: true,
          allowWakeLock: true,
          allowWifiLock: false,
        ),
      );
    } catch (e) {
      Log.w('ForegroundTask.init failed: $e');
    }

    _initialized = true;

    // Init local notifications for completion alerts
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    try {
      await _fln.initialize(initSettings);
      await _ensureCompletionChannel();
    } catch (e) {
      Log.w('Local notifications init failed: $e');
    }
  }

  /// Ensure POST_NOTIFICATIONS on Android 13+.
  static Future<void> _ensureNotificationPermission() async {
    if (!Platform.isAndroid) return;
    if (_permissionChecked) return;
    try {
      final permission =
          await FlutterForegroundTask.checkNotificationPermission();
      if (permission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
      _permissionChecked = true;
    } catch (e) {
      Log.w('Notification permission check/request failed: $e');
    }
  }

  /// Prompt to disable battery optimizations when needed.
  static Future<void> _promptBatteryOptimizationsIfNeeded() async {
    if (!Platform.isAndroid) return;
    try {
      if (_batteryPromptShown) return;
      final isEnabled =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (isEnabled == false) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
      _batteryPromptShown = true;
    } catch (e) {
      Log.v('Battery optimization prompt failed: $e');
    }
  }

  /// Start foreground service if there is at least one active runner.
  static Future<void> startIfNeeded({required int activeRunnerCount}) async {
    if (!Platform.isAndroid) return;
    if (!_initialized) await initialize();

    if (activeRunnerCount <= 0) return;

    await _ensureNotificationPermission();
    await _promptBatteryOptimizationsIfNeeded();

    try {
      final isRunning = await FlutterForegroundTask.isRunningService;
      if (!isRunning) {
        await FlutterForegroundTask.startService(
          serviceId: 101,
          notificationTitle: 'BulletDroid',
          notificationText: 'Runners active: $activeRunnerCount',
          notificationIcon: null,
          callback: _startCallback,
        );
        _serviceRunning = await FlutterForegroundTask.isRunningService;
        _currentRunnerCount = activeRunnerCount;
        _lastUpdate = DateTime.now();
      } else {
        await update(activeRunnerCount: activeRunnerCount);
      }
    } catch (e) {
      Log.w('Failed to start foreground service: $e');
    }
  }

  /// Update the persistent notification with the active runner count.
  static Future<void> update({required int activeRunnerCount}) async {
    if (!Platform.isAndroid) return;
    try {
      final running = await FlutterForegroundTask.isRunningService;
      if (!running) return;
      final now = DateTime.now();
      final elapsed = now.difference(_lastUpdate).inMilliseconds;
      if (_currentRunnerCount == activeRunnerCount &&
          elapsed < _minUpdateIntervalMs) {
        return;
      }
      await FlutterForegroundTask.updateService(
        notificationTitle: 'BulletDroid',
        notificationText: 'Runners active: $activeRunnerCount',
      );
      _currentRunnerCount = activeRunnerCount;
      _lastUpdate = now;
    } catch (e) {
      Log.v('Failed to update foreground service: $e');
    }
  }

  /// Stop the foreground service when there are no active runners.
  static Future<void> stopIfIdle({required int activeRunnerCount}) async {
    if (!Platform.isAndroid) return;
    if (activeRunnerCount > 0) return;
    try {
      final running = await FlutterForegroundTask.isRunningService;
      if (running || _serviceRunning) {
        await FlutterForegroundTask.stopService();
        _serviceRunning = await FlutterForegroundTask.isRunningService;
      }
    } catch (e) {
      Log.w('Failed to stop foreground service: $e');
    }
  }

  /// Start, update or stop based on the current active runner count.
  static Future<void> syncWithActiveRunnerCount(int activeRunnerCount) async {
    if (activeRunnerCount <= 0) {
      await stopIfIdle(activeRunnerCount: activeRunnerCount);
    } else if (!_serviceRunning) {
      await startIfNeeded(activeRunnerCount: activeRunnerCount);
    } else {
      await update(activeRunnerCount: activeRunnerCount);
    }
  }

  static Future<void> _ensureCompletionChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'runner_events',
      'Runner Events',
      description: 'Notifications for runner completion and status',
      importance: Importance.defaultImportance,
    );
    final flutterLocalNotificationsPlugin = _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await flutterLocalNotificationsPlugin?.createNotificationChannel(channel);
  }

  static Future<void> showCompletion(String configName) async {
    if (!Platform.isAndroid) return;
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'runner_events',
            'Runner Events',
            channelDescription:
                'Notifications for runner completion and status',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );
      await _fln.show(
        2001,
        'Runner finished',
        'Runner $configName finished',
        details,
      );
    } catch (e) {
      Log.v('Failed to show completion notification: $e');
    }
  }
}

@pragma('vm:entry-point')
void _startCallback() {
  FlutterForegroundTask.setTaskHandler(_NoopTaskHandler());
}

class _NoopTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}
  @override
  void onRepeatEvent(DateTime timestamp) {}
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
