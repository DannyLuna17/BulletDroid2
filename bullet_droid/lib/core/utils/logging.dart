import 'package:flutter/foundation.dart';

/// Lightweight logging helpers that can be filtered.
class Log {
  static bool verbose = false;

  static void d(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[D] $message');
    }
  }

  static void v(String message) {
    if (kDebugMode && verbose) {
      // ignore: avoid_print
      print('[V] $message');
    }
  }

  static void i(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[I] $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[W] $message');
    }
  }

  static void e(String message) {
    // ignore: avoid_print
    print('[E] $message');
  }
}
