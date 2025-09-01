import 'package:flutter/material.dart';
import 'package:bullet_droid/core/components/atoms/geist_toast.dart';
import 'package:bullet_droid/core/services/toast_service.dart';

/// BuildContext extensions for easy toast access
extension ToastExtensions on BuildContext {
  /// Show success toast
  void showSuccessToast(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    assert(message.trim().isNotEmpty, 'showSuccessToast requires non-empty message');
    if (!mounted) return;
    ToastService.showSuccess(message, actions: actions, duration: duration);
  }

  /// Show error toast
  void showErrorToast(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    assert(message.trim().isNotEmpty, 'showErrorToast requires non-empty message');
    if (!mounted) return;
    ToastService.showError(message, actions: actions, duration: duration);
  }

  /// Show warning toast
  void showWarningToast(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    assert(message.trim().isNotEmpty, 'showWarningToast requires non-empty message');
    if (!mounted) return;
    ToastService.showWarning(message, actions: actions, duration: duration);
  }

  /// Show info toast
  void showInfoToast(
    String message, {
    List<GeistToastAction>? actions,
    Duration? duration,
  }) {
    assert(message.trim().isNotEmpty, 'showInfoToast requires non-empty message');
    if (!mounted) return;
    ToastService.showInfo(message, actions: actions, duration: duration);
  }

  /// Show custom toast
  void showCustomToast(GeistToast toast) {
    if (!mounted) return;
    ToastService.show(toast);
  }

  /// Dismiss specific toast
  void dismissToast(String? toastId) {
    if (mounted) {
      ToastService.dismiss(toastId);
    }
  }

  /// Dismiss all toasts
  void dismissAllToasts() {
    if (mounted) {
      ToastService.dismissAll();
    }
  }
} 