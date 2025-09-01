import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';

/// Shadow tokens
class GeistShadows {
  // Shadow colors for different themes
  static const Color lightShadowColor = GeistColors.black;
  static const Color darkShadowColor = GeistColors.black;
  
  // Minimal shadow configurations
  static const List<BoxShadow> none = [];
  
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // Dark theme shadow variants
  static const List<BoxShadow> darkSubtle = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> darkSoft = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.4),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> darkMedium = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // Helper methods for theme-aware shadows
  static List<BoxShadow> getSubtle(bool isDark) {
    return isDark ? darkSubtle : subtle;
  }
  
  static List<BoxShadow> getSoft(bool isDark) {
    return isDark ? darkSoft : soft;
  }
  
  static List<BoxShadow> getMedium(bool isDark) {
    return isDark ? darkMedium : medium;
  }
  
  // Component-specific shadow configurations
  static List<BoxShadow> getCardShadow(bool isDark) {
    return none;
  }
  
  static List<BoxShadow> getButtonShadow(bool isDark) {
    return none;
  }
  
  static List<BoxShadow> getModalShadow(bool isDark) {
    return getSoft(isDark);
  }
  
  static List<BoxShadow> getDropdownShadow(bool isDark) {
    return getSubtle(isDark);
  }
} 