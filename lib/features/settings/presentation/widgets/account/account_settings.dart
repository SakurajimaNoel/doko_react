import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/authentication/presentation/widgets/public/remove-mfa-button/remove_mfa_button.dart';
import 'package:doko_react/features/settings/presentation/widgets/heading/settings_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsHeading.large("Account Settings"),
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        const SettingsHeading("Multi-factor Authentication"),
        BlocBuilder<UserBloc, UserState>(
          builder: (BuildContext context, UserState state) {
            if (state is! UserCompleteState) {
              return const StyledText.error(
                Constants.errorMessage,
                size: Constants.smallFontSize,
              );
            }

            if (state.userMfa) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Your account is already protected by multi-factor authentication."),
                  RemoveMfaButton(),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "Multi-factor authentication adds an extra layer of protection beyond just a password, making it significantly harder for unauthorized individuals to access your information."),
                const Text(
                    "Enhance your account security by enabling multi-factor authentication. It's quick and easy to set up."),
                TextButton(
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  ),
                  onPressed: () {
                    context.pushNamed(RouterConstants.mfaSetup);
                  },
                  child: const Text("Setup MFA"),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
