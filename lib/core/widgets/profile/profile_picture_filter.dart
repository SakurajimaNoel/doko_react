import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ProfilePictureFilter extends StatelessWidget {
  const ProfilePictureFilter({
    super.key,
    this.child = const SizedBox.shrink(),
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(Constants.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // increase to increase breakpoint
            currTheme.surface.withValues(
              alpha: 0.30,
            ),
            currTheme.surface.withValues(
              alpha: 0.25,
            ),
            currTheme.surface.withValues(
              alpha: 0.20,
            ),
            currTheme.surface.withValues(
              alpha: 0.15,
            ),
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            currTheme.surface.withValues(
              alpha: 0.15,
            ),
            currTheme.surface.withValues(
              alpha: 0.20,
            ),
            currTheme.surface.withValues(
              alpha: 0.25,
            ),
            currTheme.surface.withValues(
              alpha: 0.30,
            ),
            currTheme.surface.withValues(
              alpha: 0.35,
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
