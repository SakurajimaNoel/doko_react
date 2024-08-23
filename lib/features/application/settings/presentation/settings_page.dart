import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/provider/mfa_status_provider.dart';
import 'package:doko_react/features/application/settings/widgets/accent_widget.dart';
import 'package:doko_react/features/application/settings/widgets/theme_widget.dart';
import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  bool _removing = false;
  late final AuthenticationMFAProvider _authMFAProvider;

  @override
  void initState() {
    super.initState();
    _authMFAProvider =
        Provider.of<AuthenticationMFAProvider>(context, listen: false);
  }

  void _handleRemoveMFA() async {
    setState(() {
      _removing = true;
    });

    await AuthenticationActions.removeMFA();

    setState(() {
      _removing = false;
    });

    _showMessage("Successfully removed MFA for this account!");
    _authMFAProvider.setMFAStatus(AuthenticationMFAStatus.notSetUpped);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration:
            const Duration(milliseconds: 300), // Duration for the SnackBar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;

    return Consumer<AuthenticationMFAProvider>(
      builder: (context, mfa, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeading("User Settings"),
            const SizedBox(height: 8),
            const SettingsHeading(
              "Multi-factor Authentication",
              size: 16,
              fontWeight: FontWeight.w500,
            ),
            if (mfa.mfaStatus == AuthenticationMFAStatus.undefined) ...[
              const Text(
                  "Multi-factor authentication adds an extra layer of protection beyond just a password, making it significantly harder for unauthorized individuals to access your information.")
            ] else if (mfa.mfaStatus == AuthenticationMFAStatus.setUpped) ...[
              const Text(
                  "This account is already protected by multi-factor authentication."),
              TextButton(
                style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                onPressed: _removing ? null : _handleRemoveMFA,
                child: _removing
                    ? SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          color: currScheme.error,
                        ),
                      )
                    : Text(
                        "Remove MFA",
                        style: TextStyle(
                          color: currScheme.error,
                        ),
                      ),
              ),
            ] else ...[
              const Text(
                  "Enhance your account security by enabling multi-factor authentication. It's quick and easy to set up."),
              TextButton(
                style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                onPressed: () {
                  context.goNamed(RouterConstants.mfaSetup);
                },
                child: const Text(
                  "Setup MFA",
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
