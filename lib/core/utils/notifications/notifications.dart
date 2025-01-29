import 'package:doko_react/core/utils/notifications/notifications_helper.dart';
import 'package:flutter/material.dart';
import 'package:nice_overlay/nice_overlay.dart';

void showNotification(NiceInAppNotification notification) {
  NiceOverlay.showInAppNotification(notification);
}

void _showToast(NiceToast toast) {
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
