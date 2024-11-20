import 'package:doko_react/archive/core/configs/router/router_constants.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/provider/authentication_provider.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ErrorUnknownRoute extends StatelessWidget {
  const ErrorUnknownRoute({super.key});

  TextSpan getNextStep(BuildContext context, AuthenticationStatus authStatus,
      ProfileStatus userStatus) {
    var currTheme = Theme.of(context).colorScheme;

    if (authStatus == AuthenticationStatus.signedOut) {
      return TextSpan(
        text: "To continue, please ",
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

    if (userStatus == ProfileStatus.complete) {
      return TextSpan(
        text: "Let's head back to your ",
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
    // this page is only shown when not loading or error occurred
    final AuthenticationStatus authStatus =
        context.select((AuthenticationProvider auth) => auth.authStatus);
    final userStatus = context.select((UserProvider user) => user.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dokii"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            RichText(
              text: getNextStep(context, authStatus, userStatus),
            ),
          ],
        ),
      ),
    );
  }
}
