import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/constrained-box/expanded_box.dart';
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
      const ThemeSettings(),
      const ApplicationSettings(),
      const AccountSettings(),
    ];

    // to add separator after last item
    settingsWidgets.add(const SizedBox.shrink());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: Constants.padding,
        ),
        actions: [
          TextButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationVersion: "1.0.0",
                applicationIcon: Image.asset("assets/logo.png"),
                applicationName: "Doki",
              );
            },
            child: const Text("More info"),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(Constants.padding),
        itemCount: settingsWidgets.length,
        itemBuilder: (BuildContext context, int index) {
          return ExpandedBox(
            child: settingsWidgets[index],
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            height: Constants.gap * 2,
          );
        },
      ),
    );
  }
}
