import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:bullet_droid/core/components/atoms/geist_toast.dart';
import 'package:bullet_droid/core/router/navigation_service.dart';
import 'package:bullet_droid/core/utils/logging.dart';

/// Singleton service for global toast management.
///
/// This service uses the global navigator key from `NavigationService`
/// to insert overlay entries for toasts at the app level, so toasts can
/// be triggered from anywhere without local `BuildContext`.
class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  static ToastService get instance => _instance;

  // Active overlays keyed by toast id for dismissal.
  final Map<String, OverlayEntry> _overlaysById = <String, OverlayEntry>{};
  final Uuid _uuid = const Uuid();

  /// Show a custom toast
  static void show(GeistToast toast) {
    final safeDuration = toast.duration.inMilliseconds <= 0
        ? const Duration(milliseconds: 1500)
        : toast.duration;
    final safeToast = GeistToast(
      message: toast.message,
      variant: toast.variant,
      duration: safeDuration,
      actions: toast.actions,
      onDismiss: toast.onDismiss,
      showIcon: toast.showIcon,
      position: toast.position,
      id: toast.id,
    );
    instance._showToast(safeToast);
  }

  /// Show success toast
  static void showSuccess(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    instance._showToast(
      GeistToast(
        message: message,
        variant: GeistToastVariant.success,
        actions: actions,
        duration: duration ?? const Duration(seconds: 4),
        id: instance._uuid.v4(),
      ),
    );
  }

  /// Show error toast
  static void showError(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    instance._showToast(
      GeistToast(
        message: message,
        variant: GeistToastVariant.error,
        actions: actions,
        duration: duration ?? const Duration(seconds: 4),
        id: instance._uuid.v4(),
      ),
    );
  }

  /// Show warning toast
  static void showWarning(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    instance._showToast(
      GeistToast(
        message: message,
        variant: GeistToastVariant.warning,
        actions: actions,
        duration: duration ?? const Duration(seconds: 4),
        id: instance._uuid.v4(),
      ),
    );
  }

  /// Show info toast
  static void showInfo(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    instance._showToast(
      GeistToast(
        message: message,
        variant: GeistToastVariant.info,
        actions: actions,
        duration: duration ?? const Duration(seconds: 4),
        id: instance._uuid.v4(),
      ),
    );
  }

  /// Dismiss specific toast by ID
  static void dismiss(String? toastId) {
    if (toastId != null) {
      instance._dismissToast(toastId);
    }
  }

  /// Dismiss all active toasts
  static void dismissAll() {
    instance._dismissAllToasts();
  }

  void _showToast(GeistToast toast) {
    // Resolve app overlay from global navigator
    final navigatorState = NavigationService.navigatorKey.currentState;
    final overlay = navigatorState?.overlay;
    if (navigatorState == null || !navigatorState.mounted || overlay == null) {
      // Fallback to log if UI isn't ready
      Log.w('Toast (fallback): ${toast.message} (${toast.variant.name})');
      return;
    }

    // Ensure we have a stable id to track this overlay entry
    final String toastId = toast.id ?? _uuid.v4();

    // If a toast with the same id exists, remove it before inserting new
    final existing = _overlaysById.remove(toastId);
    existing?.remove();

    final overlayEntry = OverlayEntry(
      builder: (context) => _PositionedToast(
        toast: toast,
        onDismiss: () => _removeToastById(toastId),
      ),
    );

    _overlaysById[toastId] = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(toast.duration, () {
      if (_overlaysById.containsKey(toastId)) {
        _removeToastById(toastId);
      }
    });
  }

  void _removeToastById(String toastId) {
    final entry = _overlaysById.remove(toastId);
    entry?.remove();
  }

  void _dismissToast(String toastId) {
    _removeToastById(toastId);
  }

  void _dismissAllToasts() {
    // Remove all active overlays
    for (final entry in _overlaysById.values) {
      entry.remove();
    }
    _overlaysById.clear();
  }
}

/// Positions and animates the toast according to its requested position.
class _PositionedToast extends StatefulWidget {
  final GeistToast toast;
  final VoidCallback onDismiss;

  const _PositionedToast({required this.toast, required this.onDismiss});

  @override
  State<_PositionedToast> createState() => _PositionedToastState();
}

class _PositionedToastState extends State<_PositionedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide direction based on position
    final beginOffset = switch (widget.toast.position) {
      GeistToastPosition.top => const Offset(0, -1),
      GeistToastPosition.center => const Offset(0, 0),
      GeistToastPosition.bottom => const Offset(0, 1),
    };

    _slide = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.padding.top + 16;
    final bottomInset = media.padding.bottom + 16;

    // Position container based on toast position
    Widget positioned;
    switch (widget.toast.position) {
      case GeistToastPosition.top:
        positioned = Positioned(
          top: topInset,
          left: 16,
          right: 16,
          child: _buildInteractiveToast(),
        );
        break;
      case GeistToastPosition.center:
        positioned = Positioned.fill(
          child: Center(child: _buildInteractiveToast()),
        );
        break;
      case GeistToastPosition.bottom:
        positioned = Positioned(
          bottom: bottomInset,
          left: 16,
          right: 16,
          child: _buildInteractiveToast(isBottom: true),
        );
        break;
    }

    return positioned;
  }

  Widget _buildInteractiveToast({bool isBottom = false}) {
    return GestureDetector(
      onTap: _dismiss,
      onPanUpdate: (details) {
        // Swipe to dismiss: up for top/center, down for bottom
        final dy = details.delta.dy;
        if ((!isBottom && dy < -5) || (isBottom && dy > 5)) {
          _dismiss();
        }
      },
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _fade, child: widget.toast),
      ),
    );
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onDismiss());
  }
}
