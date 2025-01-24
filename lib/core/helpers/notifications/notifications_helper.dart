import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:nice_overlay/nice_overlay.dart';

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
            margin: EdgeInsets.only(
              right: Constants.gap * 0.5,
            ),
            child: leading,
          ),
    title: title,
    body: body,
    trailing: trailing,
    backgroundColor: currTheme.surfaceContainer,
    displayDuration: Constants.notificationDuration,
    showingAnimationDuration: Duration(
      milliseconds: 250,
    ),
    closingAnimationDuration: Duration(
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
        offset: Offset(0, 4),
      ),
    ],
    padding: EdgeInsets.all(Constants.padding),
    margin: EdgeInsets.symmetric(
      vertical: Constants.padding * 0.5,
      horizontal: Constants.padding,
    ),
  );
}
