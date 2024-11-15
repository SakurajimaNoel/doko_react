import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/debounce.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/general/bullet_list.dart';
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/features/User/data/graphql_queries/user_queries.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CompleteProfileUsernamePage extends StatefulWidget {
  const CompleteProfileUsernamePage({
    super.key,
  });

  @override
  State<CompleteProfileUsernamePage> createState() =>
      _CompleteProfileUsernamePageState();
}

class _CompleteProfileUsernamePageState
    extends State<CompleteProfileUsernamePage> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  final formKey = GlobalKey<FormState>();
  final Debounce usernameDebounce = Debounce(const Duration(
    milliseconds: 500,
  ));

  bool usernameAvailable = false;
  bool usernameSyntaxValid = false;
  String username = "";

  final List<String> usernamePattern = [
    "Be between 3 and ${Constants.usernameLimit} characters long.",
    "Start with a letter (a-z or A-Z).",
    "Contain only letters, numbers, underscores ( _ ), periods ( . ), and hyphens ( - ).",
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
        actions: [
          TextButton(
            onPressed: () {
              auth.signOutUser();
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                color: currTheme.error,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeading("Create username"),
            const Text(
                "Your username, is a unique identifier that allows others to find and connect with your profile. Once created, your username cannot be changed."),
            const SizedBox(
              height: Constants.gap * 0.5,
            ),
            const SettingsHeading(
              "Your username must:",
              size: Constants.fontSize,
            ),
            BulletList(usernamePattern),
            const SizedBox(
              height: Constants.gap * 1.5,
            ),
            Expanded(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          validator: (value) {
                            var usernameStatus =
                                ValidateInput.validateUsername(value);

                            if (usernameStatus.isValid) return null;

                            return usernameStatus.message;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (value) {
                            var usernameStatus =
                                ValidateInput.validateUsername(value);

                            if (!usernameStatus.isValid) {
                              setState(() {
                                usernameSyntaxValid = false;
                              });
                              usernameDebounce.dispose();
                              return;
                            }

                            Future<void> handleValidUsername() async {
                              usernameSyntaxValid = true;
                              username = value;

                              setState(() {});
                            }

                            usernameDebounce(() => handleValidUsername());
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Username",
                            hintText: "Username...",
                          ),
                        ),
                        const SizedBox(
                          height: Constants.gap * 0.5,
                        ),
                        if (usernameSyntaxValid)
                          Query(
                            options: QueryOptions(
                              document: gql(UserQueries.checkUsername()),
                              variables:
                                  UserQueries.checkUsernameVariables(username),
                            ),
                            builder: (QueryResult result,
                                {Refetch? refetch, FetchMore? fetchMore}) {
                              if (result.hasException) {
                                return const ErrorText(Constants.errorMessage);
                              }

                              if (result.isLoading) {
                                return Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(),
                                );
                              }

                              List? res = result.data?["users"];
                              usernameAvailable = res == null || res.isEmpty;

                              if (usernameAvailable) {
                                return ErrorText(
                                  "'$username' is available.",
                                  color: Colors.green,
                                );
                              }

                              return ErrorText("'$username' is already taken.");
                            },
                          ),
                      ],
                    ),
                    FilledButton(
                      onPressed: () {
                        if (!usernameSyntaxValid || !usernameAvailable) {
                          showMessage(
                              "To continue, please choose a unique and valid username.");
                          return;
                        }

                        context.pushNamed(
                          RouterConstants.completeProfileInfo,
                          pathParameters: {
                            "username": username,
                          },
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          Constants.buttonWidth,
                          Constants.buttonHeight,
                        ),
                      ),
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
