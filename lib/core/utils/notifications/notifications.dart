import 'package:nice_overlay/nice_overlay.dart';
import 'package:vibration/vibration.dart';

void showNotification(NiceInAppNotification notification) {
  Vibration.vibrate(
    pattern: [0, 500],
    intensities: [0, 128],
  );
  NiceOverlay.showInAppNotification(notification);
}

void showToast(NiceToast toast) {
  Vibration.vibrate(
    pattern: [0, 100],
    intensities: [0, 128],
  );
  NiceOverlay.showToast(toast);
}
