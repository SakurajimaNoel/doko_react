import 'package:flutter/material.dart';

import '../widgets/theme_settings.dart';
import '../widgets/user_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const double _padding = 16;

  @override
  void initState() {
    super.initState();
  }

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
            ThemeSettings(),
            SizedBox(height: 30),
            UserSettings(),
          ],
        ),
      ),
    );
  }
}


