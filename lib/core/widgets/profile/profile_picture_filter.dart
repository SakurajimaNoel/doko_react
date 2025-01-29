import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ProfilePictureFilter extends StatelessWidget {
  const ProfilePictureFilter({
    super.key,
    this.child = const SizedBox.shrink(),
  }) : preview = false;

  const ProfilePictureFilter.preview({
    super.key,
    this.child = const SizedBox.shrink(),
  }) : preview = true;

  final Widget child;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    if (preview) {
      return Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(Constants.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                currTheme.primary.withValues(
                  alpha: 0.75,
                ),
              ]),
        ),
        child: child,
      );
    }

    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(Constants.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            currTheme.primaryContainer.withValues(
              alpha: 0.75,
            ),
            Colors.transparent,
            currTheme.primaryContainer.withValues(
              alpha: 0.75,
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
