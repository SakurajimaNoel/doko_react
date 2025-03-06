import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:nice_overlay/nice_overlay.dart';

part "notification_helper_lib.dart";

const _shadow = Color(0xff000000);

/// [createNewNotification] is used to create [NiceInAppNotification]
NiceInAppNotification createNewNotification({
  required BuildContext context,
  Widget? body,
  VoidCallback? onTap,
  String? userKey,
  DateTime? notificationTime,
}) {
  final currTheme = Theme.of(context).colorScheme;

  return NiceInAppNotification(
    leading: userKey == null
        ? null
        : Container(
            margin: const EdgeInsets.only(
              right: Constants.gap * 0.5,
            ),
            child: UserWidget.avtar(
              userKey: userKey,
            ),
          ),
    title: userKey == null
        ? null
        : UserWidget.name(
            userKey: userKey,
            baseFontSize: Constants.smallFontSize * 1.125,
            trim: 20,
            bold: true,
          ),
    body: body,
    trailing: Text(
      formatDateTimeToTimeString(notificationTime ?? DateTime.now()),
      style: const TextStyle(
        fontSize: Constants.smallFontSize,
      ),
    ),
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
        blurRadius: 10,
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

NiceToast createNewToast({
  required String message,
  required ToastType type,
  VoidCallback? onTap,
}) {
  final backgroundColor = type == ToastType.error
      ? Colors.redAccent
      : type == ToastType.success
          ? Colors.green
          : Colors.white;
  final textColor = type == ToastType.error || type == ToastType.success
      ? Colors.white
      : Colors.black;

  return NiceToast(
    backgroundColor: backgroundColor,
    displayDuration: Constants.notificationDuration,
    showingAnimationDuration: const Duration(
      milliseconds: 250,
    ),
    closingAnimationDuration: const Duration(
      milliseconds: 250,
    ),
    onTap: onTap,
    dismissDirection: DismissDirection.up,
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
        color: _shadow.withValues(
          alpha: 0.5,
        ),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
