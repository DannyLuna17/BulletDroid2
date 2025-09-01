import 'package:flutter/widgets.dart';

/// Global navigation key holder used by routing and toast overlay logic.
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
