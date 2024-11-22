import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ErrorUnknownRoute extends StatelessWidget {
  const ErrorUnknownRoute({super.key});

  TextSpan getNextStep(BuildContext context, UserState state) {
    var currTheme = Theme.of(context).colorScheme;

    if (state is UserUnauthenticated) {
      return TextSpan(
        text: "To continue, please ",
        style: TextStyle(
          color: currTheme.onSurface,
        ),
        children: [
          TextSpan(
            text: "Login",
            style: TextStyle(
              color: currTheme.primary,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.goNamed(RouterConstants.login);
              },
          ),
          const TextSpan(text: " or "),
          TextSpan(
            text: "Sign Up.",
            style: TextStyle(
              color: currTheme.primary,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.goNamed(RouterConstants.signUp);
              },
          ),
        ],
      );
    }

    if (state is UserComplete) {
      return TextSpan(
        text: "Let's head back to your ",
        style: TextStyle(
          color: currTheme.onSurface,
        ),
        children: [
          TextSpan(
            text: "homepage.",
            style: TextStyle(
              color: currTheme.primary,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.goNamed(RouterConstants.userFeed);
              },
          ),
        ],
      );
    }

    return TextSpan(
      text: "Your profile is almost there! Please ",
      style: TextStyle(
        color: currTheme.onSurface,
      ),
      children: [
        TextSpan(
          text: "complete",
          style: TextStyle(
            color: currTheme.primary,
            fontWeight: FontWeight.w500,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              context.goNamed(RouterConstants.completeProfileUsername);
            },
        ),
        const TextSpan(
          text: " it to access all features.",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // todo: check for padding in rich text
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doki"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Looks like you've wandered off!",
              style: TextStyle(
                fontSize: Constants.largeFontSize,
              ),
            ),
            const SizedBox(
              height: Constants.gap,
            ),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return RichText(
                  text: getNextStep(context, state),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
