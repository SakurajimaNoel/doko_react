import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:doko_react/features/application/settings/widgets/theme_widget.dart';
import 'package:flutter/material.dart';

import 'accent_widget.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsHeading("Theme Settings"),
        SizedBox(height: 8),
        SettingsHeading(
          "Application Mode",
          size: 16,
          fontWeight: FontWeight.w500,
        ),
        ThemeWidget(),
        SizedBox(height: 8),
        SettingsHeading(
          "Application Accent",
          size: 16,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 8),
        AccentWidget(),
      ],
    );
  }
}