import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bullet_droid/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/core/components/organisms/mobile_navigation.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final location = router.routerDelegate.currentConfiguration.uri.toString();

    // Hide floating navigation on specific routes
    const toHide = <String>{AppPath.runner, AppPath.hitsDb, AppPath.customWordlistTypes};

    final showFloatingNav =
        (!toHide.any(location.startsWith) || (location.startsWith('/configs')));

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          child,

          // Floating navigation overlay
          if (showFloatingNav)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: _RedesignedBottomNavBar()),
            ),
        ],
      ),
    );
  }
}

class _RedesignedBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final location = router.routerDelegate.currentConfiguration.uri.toString();

    // Determine selected index based on current location
    int selectedIndex = 0;
    if (location.startsWith(AppPath.dashboard)) {
      selectedIndex = 0;
    } else if (location.startsWith(AppPath.configs)) {
      selectedIndex = 1;
    } else if (location.startsWith(AppPath.wordlists)) {
      selectedIndex = 2;
    } else if (location.startsWith(AppPath.proxies)) {
      selectedIndex = 3;
    } else if (location.startsWith(AppPath.settings)) {
      selectedIndex = 4;
    }

    return MobileNavigation(
      type: MobileNavType.floating,
      selectedIndex: selectedIndex,
      onItemTapped: (index) {
        switch (index) {
          case 0:
            context.go(AppPath.dashboard);
            break;
          case 1:
            context.go(AppPath.configs);
            break;
          case 2:
            context.go(AppPath.wordlists);
            break;
          case 3:
            context.go(AppPath.proxies);
            break;
          case 4:
            context.go(AppPath.settings);
            break;
        }
      },
      items: const [
        MobileNavItem(icon: Icons.dashboard_outlined),
        MobileNavItem(icon: Icons.description_outlined),
        MobileNavItem(icon: Icons.list_alt_outlined),
        MobileNavItem(icon: Icons.vpn_lock_outlined),
        MobileNavItem(icon: Icons.settings_outlined),
      ],
    );
  }
}
