import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/widgets/loader.dart';
import 'package:doko_react/features/application/settings/widgets/theme_widget.dart';
import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const double _padding = 16;
  bool? _mfaSetup;
  bool _removing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _fetchMfaStatus();
  }

  void _fetchMfaStatus() async {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final currentPreference = await cognitoPlugin.fetchMfaPreference();
    setState(() {
      _mfaSetup = currentPreference.preferred != null;
      _loading = false;
    });
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
    _fetchMfaStatus();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration:
            const Duration(milliseconds: 300), // Duration for the Snackbar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;
    final mfaSetup = _mfaSetup;

    return Scaffold(
      appBar: AppBar(),
      body: _loading
          ? const Center(
              child: Loader(),
            )
          : Padding(
              padding: const EdgeInsets.only(
                  left: _padding, right: _padding, bottom: _padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsHeading("Theme Settings"),
                      SizedBox(height: 8),
                      ThemeWidget(),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SettingsHeading("User Settings"),
                      const SizedBox(height: 8),
                      const SettingsHeading(
                        "Multi-factor Authentication",
                        size: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      if (mfaSetup == null) ...[
                        const Text(
                            "Multi-factor authentication adds an extra layer of protection beyond just a password, making it significantly harder for unauthorized individuals to access your information.")
                      ] else if (mfaSetup) ...[
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
                  ),
                ],
              ),
            ),
    );
  }
}
