/// Spacing tokens for BulletDroid
class GeistSpacing {
  // Base spacing unit
  static const double base = 4.0;

  // Spacing scale
  static const double xs = base;
  static const double sm = base * 2;
  static const double md = base * 3;
  static const double lg = base * 4;
  static const double xl = base * 6;
  static const double xxl = base * 8;
  static const double xxxl = base * 12;
  static const double xxxxl = base * 16;

  // Semantic spacing tokens
  static const double padding = md;
  static const double margin = lg;
  static const double gap = sm;
  static const double section = xl;

  // Component-specific spacing
  static const double buttonPadding = md;
  static const double cardPadding = lg;
  static const double listItemPadding = md;
  static const double inputPadding = md;

  // Layout spacing
  static const double screenPadding = lg;
  static const double sectionGap = xl;
  static const double componentGap = md;

  // Responsive multipliers
  static const double mobileMultiplier = 1.0;
  static const double tabletMultiplier = 1.25;
  static const double desktopMultiplier = 1.5;

  // Touch target sizes
  static const double touchTargetMin = 44.0;
  static const double touchTargetComfortable = 48.0;
  static const double touchTargetLarge = 56.0;

  // Border radius tokens
  static const double borderRadiusSmall = 2.0;
  static const double borderRadiusMedium = 4.0;
  static const double borderRadiusLarge = 8.0;

  // Border width tokens
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;

  // Helper methods for responsive spacing
  static double responsive(
    double baseValue, {
    required double screenWidth,
    double mobileBreakpoint = 768.0,
    double tabletBreakpoint = 1024.0,
  }) {
    if (screenWidth < mobileBreakpoint) {
      return baseValue * mobileMultiplier;
    } else if (screenWidth < tabletBreakpoint) {
      return baseValue * tabletMultiplier;
    } else {
      return baseValue * desktopMultiplier;
    }
  }

  // Spacing for data-dense interfaces
  static const double tableCellPadding = sm;
  static const double tableRowHeight = 40.0;
  static const double tableHeaderHeight = 44.0;

  // Navigation spacing
  static const double navItemPadding = md;
  static const double navItemHeight = touchTargetMin;
  static const double navSectionGap = lg;
}
