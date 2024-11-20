import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/archive/features/application/settings/widgets/accent_widget.dart';
import 'package:doko_react/archive/features/application/settings/widgets/theme_widget.dart';
import 'package:flutter/material.dart';

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
        SizedBox(
          height: Constants.gap * 0.5,
        ),
        SettingsHeading(
          "Application Mode",
          size: Constants.fontSize,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(
          height: Constants.gap * 0.25,
        ),
        ThemeWidget(),
        SizedBox(
          height: Constants.gap * 0.75,
        ),
        SettingsHeading(
          "Application Accent",
          size: Constants.fontSize,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(
          height: Constants.gap * 0.5,
        ),
        AccentWidget(),
      ],
    );
  }
}
