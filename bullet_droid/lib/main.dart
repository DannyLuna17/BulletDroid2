import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/core/theme/app_theme.dart';
import 'package:bullet_droid/core/router/app_router.dart';
import 'package:bullet_droid/shared/providers/app_init_provider.dart';
import 'package:bullet_droid/core/services/background_service.dart';
import 'package:bullet_droid/core/services/image_precache_service.dart';

void main() async {
  // App entrypoint. Ensure that Flutter bindings are ready, then the
  // Foreground service. After that, provide Riverpod at the root and render the app.
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    BackgroundService.initialize();
  });

  runApp(const ProviderScope(child: BulletDroidApp()));
}

class BulletDroidApp extends ConsumerWidget {
  const BulletDroidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for app data initialization
    final appInit = ref.watch(appDataInitProvider);

    return appInit.when(
      data: (_) {
        // App data is loaded
        final router = ref.watch(routerProvider);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ImagePrecacheService.precacheAppImages(context);
        });

        return MaterialApp.router(
          title: 'BulletDroid',
          theme: AppTheme.lightTheme(),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => MaterialApp(
        title: 'BulletDroid',
        theme: AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        home: const _StartupLoadingScreen(),
      ),
      error: (error, stack) => MaterialApp(
        title: 'BulletDroid',
        theme: AppTheme.lightTheme(),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ImagePrecacheService.precacheAppImages(context);
          });
          return child!;
        },
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load app data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Invalidate the provider to retry loading
                    ref.invalidate(appDataInitProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ImagePrecacheService.precacheAppImages(context);
    });
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 128,
                  height: 128,
                ),
              ),
              // Title
              Text(
                'BulletDroid',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              // Subtext
              Text(
                'Loading configs, wordlists and runners…',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              // Progress
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
