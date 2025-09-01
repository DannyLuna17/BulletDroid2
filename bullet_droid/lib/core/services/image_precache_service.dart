import 'package:flutter/material.dart';

/// Pre-caches commonly used asset images once at app startup
class ImagePrecacheService {
  ImagePrecacheService._();

  static bool _didRun = false;

  static Future<void> precacheAppImages(BuildContext context) async {
    if (_didRun) return;

    final List<Future<void>> futures = [
      precacheImage(const AssetImage('assets/icons/app_icon.png'), context),
      precacheImage(const AssetImage('assets/icons/github-logo.png'), context),
    ];

    try {
      await Future.wait(futures);
    } finally {
      _didRun = true;
    }
  }
}


