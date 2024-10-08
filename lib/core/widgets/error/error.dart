import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Error extends StatelessWidget {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  Error({
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
                  auth.signOutUser();
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
