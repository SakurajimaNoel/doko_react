import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignOutButton extends StatefulWidget {
  const SignOutButton({super.key});

  @override
  State<SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<SignOutButton> {
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  void stateActions(BuildContext context, AuthenticationState state) {
    String errorMessage = (state as AuthenticationError).message;
    showMessage(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => serviceLocator<AuthenticationBloc>(),
      child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previousState, state) {
          return state is AuthenticationError;
        },
        listener: stateActions,
        builder: (context, state) {
          return FilledButton(
            onPressed: () {
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            style: FilledButton.styleFrom(
              backgroundColor: currTheme.error,
              minimumSize: Size.zero,
              padding: EdgeInsets.symmetric(
                vertical: Constants.padding * 0.5,
                horizontal: Constants.padding * 0.75,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Sign out",
              style: TextStyle(
                color: currTheme.onError,
                fontSize: Constants.smallFontSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
