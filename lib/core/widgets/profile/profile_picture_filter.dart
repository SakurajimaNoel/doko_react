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
            currTheme.surface.withOpacity(0.25),
            currTheme.surface.withOpacity(0.15),
            currTheme.surface.withOpacity(0.05),
            currTheme.surface.withOpacity(0.025),
            currTheme.surface.withOpacity(0.025),
            currTheme.surface.withOpacity(0.025),
            currTheme.surface.withOpacity(0.025),
            currTheme.surface.withOpacity(0.05),
            currTheme.surface.withOpacity(0.15),
            currTheme.surface.withOpacity(0.25),
          ],
        ),
      ),
      child: child,
    );
  }
}
