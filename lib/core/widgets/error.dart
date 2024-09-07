import 'package:doko_react/core/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth.dart';
import '../provider/authentication_provider.dart';
import 'error_widget.dart';

class Error extends StatelessWidget {
  const Error({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authStatus =
        context.select((AuthenticationProvider auth) => auth.authStatus);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ErrorText(
                "Oops! Something went wrong. Please try again later."),
            if (authStatus == AuthenticationStatus.signedIn) ...[
              const SizedBox(
                height: Constants.gap,
              ),
              ElevatedButton(
                onPressed: () {
                  AuthenticationActions.signOutUser();
                },
                child: const Text("Sign Out"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
