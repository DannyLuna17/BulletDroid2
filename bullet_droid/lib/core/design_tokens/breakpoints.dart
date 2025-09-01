import 'package:flutter/material.dart';

// Device type enumeration
enum DeviceType {
  mobile,
  mobileLarge,
  tablet,
  tabletLarge,
  desktop,
  desktopLarge,
  desktopXL,
}

/// Breakpoint tokens
class GeistBreakpoints {
  // Breakpoint values
  static const double mobile = 320.0;
  static const double mobileLarge = 480.0;
  static const double tablet = 768.0;
  static const double tabletLarge = 1024.0;
  static const double desktop = 1024.0;
  static const double desktopLarge = 1440.0;
  static const double desktopXL = 1920.0;

  // Helper methods for responsive design
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  static bool isMobileLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileLarge &&
        MediaQuery.of(context).size.width < tablet;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet &&
        MediaQuery.of(context).size.width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isDesktopLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopLarge;
  }

  // Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileLarge) {
      return DeviceType.mobile;
    } else if (width < tablet) {
      return DeviceType.mobileLarge;
    } else if (width < tabletLarge) {
      return DeviceType.tablet;
    } else if (width < desktop) {
      return DeviceType.tabletLarge;
    } else if (width < desktopLarge) {
      return DeviceType.desktop;
    } else if (width < desktopXL) {
      return DeviceType.desktopLarge;
    } else {
      return DeviceType.desktopXL;
    }
  }

  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? mobileLarge,
    T? tablet,
    T? tabletLarge,
    T? desktop,
    T? desktopLarge,
    T? desktopXL,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.mobileLarge:
        return mobileLarge ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobileLarge ?? mobile;
      case DeviceType.tabletLarge:
        return tabletLarge ?? tablet ?? mobileLarge ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tabletLarge ?? tablet ?? mobileLarge ?? mobile;
      case DeviceType.desktopLarge:
        return desktopLarge ??
            desktop ??
            tabletLarge ??
            tablet ??
            mobileLarge ??
            mobile;
      case DeviceType.desktopXL:
        return desktopXL ??
            desktopLarge ??
            desktop ??
            tabletLarge ??
            tablet ??
            mobileLarge ??
            mobile;
    }
  }

  static double getScreenPadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  static int getGridColumns(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 1,
      mobileLarge: 2,
      tablet: 2,
      tabletLarge: 3,
      desktop: 4,
    );
  }

  static double getMaxContentWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 768.0,
      desktop: 1200.0,
      desktopLarge: 1400.0,
    );
  }
}
