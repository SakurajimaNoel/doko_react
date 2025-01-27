import 'package:doko_react/core/utils/notifications/notifications_helper.dart';
import 'package:flutter/material.dart';
import 'package:nice_overlay/nice_overlay.dart';
import 'package:vibration/vibration.dart';

void showNotification(NiceInAppNotification notification) {
  Vibration.vibrate(
    pattern: [0, 500],
    intensities: [0, 128],
  );
  NiceOverlay.showInAppNotification(notification);
}

void _showToast(NiceToast toast) {
  // Vibration.vibrate(
  //   pattern: [0, 100],
  //   intensities: [0, 128],
  // );
  NiceOverlay.showToast(toast);
}

void showError(BuildContext context, String message) {
  _showToast(createNewToast(
    context,
    message: message,
    type: ToastType.error,
  ));
}

void showInfo(BuildContext context, String message) {
  _showToast(createNewToast(
    context,
    message: message,
    type: ToastType.normal,
  ));
}

void showSuccess(BuildContext context, String message) {
  _showToast(createNewToast(
    context,
    message: message,
    type: ToastType.success,
  ));
}
