import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/settings/presentation/widgets/account/account_settings.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Constants.padding),
        children: const [
          ThemeSettings(),
          _SettingsDivider(),
          AccountSettings(),
          _SettingsDivider(),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: Constants.gap * 2,
    );
  }
}
