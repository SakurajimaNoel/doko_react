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
      padding: const EdgeInsets.only(
        top: Constants.padding,
        left: Constants.padding,
        right: Constants.padding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
            0,
            0.425,
            0.75,
            0.875,
            0.925,
            1,
          ],
          colors: [
            currTheme.primaryContainer.withValues(
              alpha: 0.625,
            ),
            Colors.transparent,
            Colors.transparent,
            currTheme.surface.withValues(
              alpha: 0.25,
            ),
            currTheme.surface.withValues(
              alpha: 0.625,
            ),
            currTheme.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}
