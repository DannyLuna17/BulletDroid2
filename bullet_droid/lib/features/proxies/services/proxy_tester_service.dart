import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/features/proxies/models/proxy_model.dart';

/// Riverpod provider for the proxy tester service
final proxyTesterServiceProvider = Provider<ProxyTesterService>((ref) {
  return ProxyTesterService();
});

class ProxyTesterService {
  Timer? _periodicPersistTimer;
  bool _running = false;

  bool get isRunning => _running;

  Future<void> runTesting({
    required List<ProxyModel> proxies,
    required int concurrency,
    required Future<void> Function(ProxyModel proxy) testSingleProxy,
    required void Function() flushPendingUpdates,
    required bool Function() shouldContinue,
    Duration persistInterval = const Duration(seconds: 5),
    int maxStartsPerSecond = 200,
  }) async {
    if (proxies.isEmpty) return;
    _running = true;

    // Periodic persistence
    _periodicPersistTimer?.cancel();
    _periodicPersistTimer = Timer.periodic(persistInterval, (_) {
      try {
        flushPendingUpdates();
      } catch (_) {}
    });

    final int total = proxies.length;
    final int maxConcurrency = concurrency <= 0
        ? 1
        : (concurrency > total ? total : concurrency);

    // Distribute starts across 100ms ticks
    final int permitsPerTick = (maxStartsPerSecond ~/ 10).clamp(1, 1000);
    const Duration tick = Duration(milliseconds: 100);

    int inFlight = 0;
    int nextIndex = 0;
    final List<Completer<void>> running = [];

    Future<void> startNext() async {
      if (!_running || !shouldContinue()) return;
      if (nextIndex >= total) return;
      final index = nextIndex++;
      inFlight++;
      try {
        await testSingleProxy(proxies[index]);
      } finally {
        inFlight--;
      }
    }

    while (_running &&
        shouldContinue() &&
        (nextIndex < total || inFlight > 0)) {
      int startedThisTick = 0;
      while (_running &&
          shouldContinue() &&
          startedThisTick < permitsPerTick &&
          inFlight < maxConcurrency &&
          nextIndex < total) {
        final completer = Completer<void>();
        running.add(completer);
        startNext().whenComplete(() {
          if (!completer.isCompleted) completer.complete();
        });
        startedThisTick++;
      }
      await Future.delayed(tick);
      // Drop completed tasks to avoid memory accumulation
      running.removeWhere((c) => c.isCompleted);
    }

    // Ensure all tasks are done
    try {
      await Future.wait(running.map((c) => c.future), eagerError: false);
    } finally {
      try {
        flushPendingUpdates();
      } catch (_) {}
      stop();
    }
  }

  void stop() {
    _running = false;
    _periodicPersistTimer?.cancel();
    _periodicPersistTimer = null;
  }
}
