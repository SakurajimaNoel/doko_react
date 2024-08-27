
import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/configs/router/router_constants.dart';
import '../../../../core/provider/mfa_status_provider.dart';
import '../../../authentication/data/auth.dart';

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
            const SizedBox(height: 8),
            const SettingsHeading(
              "Update password",
              size: 16,
              fontWeight: FontWeight.w500,
            ),
            const Text(
                "Consider changing your password every few months to enhance security."),
            TextButton(
              style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.zero)),
              onPressed: () {
                context.goNamed(RouterConstants.changePassword);
              },
              child: const Text(
                "Update password",
              ),
            ),
          ],
        );
      },
    );
  }
}
