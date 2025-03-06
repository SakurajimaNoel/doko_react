import 'dart:ui';

import 'package:doko_react/core/utils/notifications/notifications_helper.dart';
import 'package:nice_overlay/nice_overlay.dart';

void showNotification(NiceInAppNotification notification) {
  NiceOverlay.showInAppNotification(notification);
}

void _showToast(NiceToast toast) {
  NiceOverlay.showToast(toast);
}

void showError(
  String message, {
  VoidCallback? onTap,
}) {
  _showToast(createNewToast(
    message: message,
    type: ToastType.error,
    onTap: onTap,
  ));
}

void showInfo(
  String message, {
  VoidCallback? onTap,
}) {
  _showToast(createNewToast(
    message: message,
    type: ToastType.normal,
    onTap: onTap,
  ));
}

void showSuccess(
  String message, {
  VoidCallback? onTap,
}) {
  _showToast(createNewToast(
    message: message,
    type: ToastType.success,
    onTap: onTap,
  ));
}
