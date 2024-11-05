import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/debounce.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/general/bullet_list.dart';
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  final UserGraphqlService _graphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );
  final _formKey = GlobalKey<FormState>();
  final Debounce _usernameDebounce = Debounce(const Duration(
    milliseconds: 500,
  ));

  // bool _loading = false;
  String _username = "";
  String _apiErrorMessage = "";
  bool _usernameAvailable = false;

  final List<String> usernamePattern = [
    "Be between 3 and ${Constants.usernameLimit} characters long.",
    "Start with a letter (a-z or A-Z).",
    "Contain only letters, numbers, underscores ( _ ), periods ( . ), and hyphens ( - ).",
  ];

  Future<void> _isAvailable(String username) async {
    var usernameResponse = await _graphqlService.checkUsername(username);
    String message = "";
    bool available = true;

    if (usernameResponse.status == ResponseStatus.error) {
      message = "Oops! Something went wrong. Please try again later.";
      available = false;
    }

    if (usernameResponse.status == ResponseStatus.success &&
        !usernameResponse.available) {
      message = "'$_username' is already taken.";
      available = false;
    }

    setState(() {
      _apiErrorMessage = message;
      _usernameAvailable = available;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete profile"),
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
                key: _formKey,
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
                          onSaved: (value) {
                            if (value == null || value.isEmpty) {
                              return;
                            }

                            _username = value.trim();
                          },
                          onChanged: (value) {
                            setState(() {
                              _usernameAvailable = false;
                              _apiErrorMessage = "";
                              _username = value;
                            });
                            var usernameStatus =
                                ValidateInput.validateUsername(value);

                            if (!usernameStatus.isValid) {
                              _usernameDebounce.dispose();
                              return;
                            }

                            _usernameDebounce(() => _isAvailable(value));
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
                        if (_apiErrorMessage.isNotEmpty)
                          ErrorText(_apiErrorMessage),
                        if (_usernameAvailable)
                          ErrorText(
                            "'$_username' is available.",
                            color: Colors.green,
                          ),
                      ],
                    ),
                    FilledButton(
                      onPressed: !_usernameAvailable
                          ? null
                          : () {
                              context.goNamed(
                                RouterConstants.completeProfileInfo,
                                pathParameters: {
                                  "username": _username,
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
