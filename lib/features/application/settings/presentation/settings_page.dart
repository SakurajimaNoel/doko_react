import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/features/application/settings/widgets/theme_settings.dart';
import 'package:doko_react/features/application/settings/widgets/user_settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsHeading(
          "Settings",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Constants.padding),
        children: const [
          ThemeSettings(),
          SizedBox(
            height: Constants.gap * 2,
          ),
          UserSettings(),
        ],
      ),
    );
  }
}
