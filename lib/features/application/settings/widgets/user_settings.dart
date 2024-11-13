import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/core/widgets/loader/loader_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({
    super.key,
  });

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  bool _removing = false;
  late final AuthenticationProvider _authenticationProvider;

  @override
  void initState() {
    super.initState();
    _authenticationProvider = context.read<AuthenticationProvider>();
  }

  void _handleRemoveMFA() async {
    setState(() {
      _removing = true;
    });

    await auth.removeMFA();

    setState(() {
      _removing = false;
    });

    _showMessage("Successfully removed MFA for this account!");
    _authenticationProvider.setMFAStatus(AuthenticationMFAStatus.notSetUpped);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;
    final mfaStatus =
        context.select((AuthenticationProvider auth) => auth.mfaStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeading("User Settings"),
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        const SettingsHeading(
          "Multi-factor Authentication",
          size: Constants.fontSize,
          fontWeight: FontWeight.w500,
        ),
        if (mfaStatus == AuthenticationMFAStatus.undefined) ...[
          const Text(
              "Multi-factor authentication adds an extra layer of protection beyond just a password, making it significantly harder for unauthorized individuals to access your information.")
        ] else if (mfaStatus == AuthenticationMFAStatus.setUpped) ...[
          const Text(
              "This account is already protected by multi-factor authentication."),
          TextButton(
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
            ),
            onPressed: _removing ? null : _handleRemoveMFA,
            child: _removing
                ? LoaderButton(
                    width: Constants.width,
                    height: Constants.height,
                    color: currScheme.error,
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
              padding: WidgetStatePropertyAll(EdgeInsets.zero),
            ),
            onPressed: () {
              context.goNamed(RouterConstants.mfaSetup);
            },
            child: const Text(
              "Setup MFA",
            ),
          ),
        ],
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        const SettingsHeading(
          "Update password",
          size: Constants.fontSize,
          fontWeight: FontWeight.w500,
        ),
        const Text(
            "Consider changing your password every few months to enhance security."),
        TextButton(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
          ),
          onPressed: () {
            context.goNamed(RouterConstants.changePassword);
          },
          child: const Text(
            "Update password",
          ),
        ),
      ],
    );
  }
}
