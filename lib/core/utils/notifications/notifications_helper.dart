import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:nice_overlay/nice_overlay.dart';

part "notification_helper_lib.dart";

/// [createNewNotification] is used to create [NiceInAppNotification]
NiceInAppNotification createNewNotification({
  required BuildContext context,
  Widget? leading,
  Widget? title,
  Widget? body,
  Widget? trailing,
  VoidCallback? onTap,
}) {
  final currTheme = Theme.of(context).colorScheme;

  return NiceInAppNotification(
    vibrate: false,
    leading: leading == null
        ? null
        : Container(
            margin: const EdgeInsets.only(
              right: Constants.gap * 0.5,
            ),
            child: leading,
          ),
    title: title,
    body: body,
    trailing: trailing,
    backgroundColor: currTheme.surfaceContainer,
    displayDuration: Constants.notificationDuration,
    showingAnimationDuration: const Duration(
      milliseconds: 250,
    ),
    closingAnimationDuration: const Duration(
      milliseconds: 250,
    ),
    onTap: onTap,
    boxShadows: [
      BoxShadow(
        color: currTheme.shadow.withValues(
          alpha: 0.5,
        ),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 2),
      ),
    ],
    padding: const EdgeInsets.all(Constants.padding),
    margin: const EdgeInsets.symmetric(
      vertical: Constants.padding * 0.5,
      horizontal: Constants.padding,
    ),
  );
}

NiceToast createNewToast(
  BuildContext context, {
  required String message,
  required ToastType type,
}) {
  final currTheme = Theme.of(context).colorScheme;
  final backgroundColor = type == ToastType.error
      ? currTheme.errorContainer
      : type == ToastType.success
          ? Colors.green
          : currTheme.inverseSurface;
  final textColor = type == ToastType.error
      ? currTheme.onErrorContainer
      : type == ToastType.success
          ? Colors.white
          : currTheme.onInverseSurface;

  return NiceToast(
    backgroundColor: backgroundColor,
    displayDuration: Constants.notificationDuration,
    showingAnimationDuration: const Duration(
      milliseconds: 250,
    ),
    closingAnimationDuration: const Duration(
      milliseconds: 250,
    ),
    dismissDirection: DismissDirection.up,
    vibrate: false,
    message: Text(
      message,
      style: TextStyle(
        color: textColor,
      ),
    ),
    niceToastPosition: NiceToastPosition.top,
    margin: const EdgeInsets.symmetric(
      vertical: Constants.padding * 0.5,
      horizontal: Constants.padding,
    ),
    boxShadows: [
      BoxShadow(
        color: currTheme.shadow.withValues(
          alpha: 0.5,
        ),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
