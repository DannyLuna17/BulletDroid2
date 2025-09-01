import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:bullet_droid/shared/providers/hive_provider.dart';

final runnerUiStateServiceProvider = Provider<RunnerUiStateService>((ref) {
  return RunnerUiStateService(ref);
});

class RunnerUiStateService {
  final Ref _ref;
  RunnerUiStateService(this._ref);

  static const String _keyBottomExpanded = 'runnerBottomExpanded';

  bool getBottomExpanded({bool defaultValue = true}) {
    try {
      final Box box = _ref.read(settingsBoxProvider);
      return box.get(_keyBottomExpanded, defaultValue: defaultValue) as bool;
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> setBottomExpanded(bool value) async {
    try {
      final Box box = _ref.read(settingsBoxProvider);
      await box.put(_keyBottomExpanded, value);
    } catch (_) {
    }
  }
}
