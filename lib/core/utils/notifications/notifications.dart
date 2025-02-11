import 'package:doko_react/core/utils/notifications/notifications_helper.dart';
import 'package:nice_overlay/nice_overlay.dart';

void showNotification(NiceInAppNotification notification) {
  NiceOverlay.showInAppNotification(notification);
}

void _showToast(NiceToast toast) {
  NiceOverlay.showToast(toast);
}

void showError(String message) {
  _showToast(createNewToast(
    message: message,
    type: ToastType.error,
  ));
}

void showInfo(String message) {
  _showToast(createNewToast(
    message: message,
    type: ToastType.normal,
  ));
}

void showSuccess(String message) {
  _showToast(createNewToast(
    message: message,
    type: ToastType.success,
  ));
}
