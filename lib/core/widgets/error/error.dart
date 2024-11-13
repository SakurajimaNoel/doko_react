import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/widgets/general/bullet_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Error extends StatelessWidget {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);
  final List<String> steps = [
    "Sometimes, a simple app restart can clear up unexpected errors. Please give it a try."
  ];
  final List<String> authSteps = ["Try signing out and logging back in."];

  Error({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authStatus =
        context.select((AuthenticationProvider auth) => auth.authStatus);

    final List<String> displaySteps = List.from(steps);
    if (authStatus == AuthenticationStatus.signedIn) {
      displaySteps.addAll(authSteps);
    }

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
              "We're sorry, but something went wrong. Please let us know if you continue to experience problems.",
              style: TextStyle(
                fontSize: Constants.fontSize,
              ),
            ),
            const SizedBox(
              height: Constants.gap,
            ),
            const Text("Here are some steps you can try:"),
            const SizedBox(
              height: Constants.gap * 0.5,
            ),
            BulletList(displaySteps),
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
            ],
          ],
        ),
      ),
    );
  }
}
