import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoveMfaButton extends StatefulWidget {
  const RemoveMfaButton({super.key});

  @override
  State<RemoveMfaButton> createState() => _RemoveMfaButtonState();
}

class _RemoveMfaButtonState extends State<RemoveMfaButton> {
  void stateActions(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationRemoveMFASuccess) {
      context.read<UserBloc>().add(UserUpdateMFAEvent(
            mfaStatus: false,
          ));
      return;
    }
    String errorMessage = (state as AuthenticationError).message;
    showError(context, errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return BlocProvider(
        create: (context) => serviceLocator<AuthenticationBloc>(),
        child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listener: stateActions,
          listenWhen: (previousState, state) {
            return (state is AuthenticationRemoveMFASuccess ||
                    state is AuthenticationError) &&
                previousState != state;
          },
          builder: (context, state) {
            bool removing = state is AuthenticationLoading;

            return TextButton(
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
              ),
              onPressed: removing
                  ? null
                  : () {
                      context.read<AuthenticationBloc>().add(RemoveMFAEvent());
                    },
              child: removing
                  ? SmallLoadingIndicator(
                      color: currTheme.error,
                    )
                  : Text(
                      "Remove MFA",
                      style: TextStyle(
                        color: currTheme.error,
                      ),
                    ),
            );
          },
        ));
  }
}
