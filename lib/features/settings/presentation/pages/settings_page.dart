import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/settings/presentation/widgets/account/account_settings.dart';
import 'package:doko_react/features/settings/presentation/widgets/application/application_settings.dart';
import 'package:doko_react/features/settings/presentation/widgets/theme/theme_settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> settingsWidgets = [
      ThemeSettings(),
      ApplicationSettings(),
      AccountSettings(),
    ];

    // to add separator after last item
    settingsWidgets.add(SizedBox.shrink());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Constants.padding),
        itemCount: settingsWidgets.length,
        itemBuilder: (BuildContext context, int index) {
          return settingsWidgets[index];
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: Constants.gap * 2,
          );
        },
      ),
    );
  }
}
