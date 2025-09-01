import 'package:bullet_droid/features/runner/models/job_progress.dart';

class CPMCalculator {
  static int calculateCPM(List<ValidDataResult> allResults) {
    if (allResults.isEmpty) return 0;

    final now = DateTime.now();
    var count = 0;

    // Count results within the last 60 seconds
    for (int i = allResults.length - 1; i >= 0; i--) {
      final result = allResults[i];
      final secondsAgo = now.difference(result.completionTime).inSeconds;

      if (secondsAgo > 60) break;
      count++;
    }

    return count;
  }

  /// Cleans up old results beyond 5-minute window to prevent memory issues
  static void cleanupOldResults(List<ValidDataResult> results) {
    if (results.isEmpty) return;

    final now = DateTime.now();
    const fiveMinutesInSeconds = 300;

    results.removeWhere(
      (result) =>
          now.difference(result.completionTime).inSeconds >
          fiveMinutesInSeconds,
    );
  }

  /// Combines all result lists and calculates CPM efficiently
  /// This method is called every 500ms to provide real-time CPM updates
  static int calculateCPMFromLists({
    required List<ValidDataResult> hits,
    required List<ValidDataResult> fails,
    required List<ValidDataResult> customs,
    required List<ValidDataResult> toChecks,
  }) {
    final now = DateTime.now();
    var count = 0;

    // Count results from each list
    count += _countRecentResults(hits, now);
    count += _countRecentResults(fails, now);
    count += _countRecentResults(customs, now);
    count += _countRecentResults(toChecks, now);

    return count;
  }

  /// Efficiently counts results within 60 seconds from a single list
  static int _countRecentResults(List<ValidDataResult> results, DateTime now) {
    var count = 0;
    for (final result in results) {
      if (now.difference(result.completionTime).inSeconds <= 60) {
        count++;
      }
    }
    return count;
  }
}
