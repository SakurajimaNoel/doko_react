import 'package:flutter/material.dart';

import '../../../../core/helpers/constants.dart';
import '../widgets/settings_heading.dart';
import '../widgets/theme_settings.dart';
import '../widgets/user_settings.dart';

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
