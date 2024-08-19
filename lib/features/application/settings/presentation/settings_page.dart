import 'package:doko_react/core/widgets/theme_widget.dart';
import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const double _padding = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Padding(
        padding:
        EdgeInsets.only(left: _padding, right: _padding, bottom: _padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsHeading("Theme Settings"),
            SizedBox(height: 8),
            ThemeWidget(),
          ],
        ),
      ),
    );
  }
}
