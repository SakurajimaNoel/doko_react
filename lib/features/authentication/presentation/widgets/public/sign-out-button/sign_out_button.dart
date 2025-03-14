import 'package:doko_react/core/utils/notifications/notifications.dart';
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
  void stateActions(BuildContext context, AuthenticationState state) {
    String errorMessage = (state as AuthenticationError).message;
    showError(errorMessage);
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
          return TextButton(
            onPressed: () {
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            style: TextButton.styleFrom(
              // backgroundColor: currTheme.error,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Sign out",
              style: TextStyle(
                color: currTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}
