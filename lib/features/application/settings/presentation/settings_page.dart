import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/provider/mfa_status_provider.dart';
import 'package:doko_react/features/application/settings/widgets/accent_widget.dart';
import 'package:doko_react/features/application/settings/widgets/theme_widget.dart';
import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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


