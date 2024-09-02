import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/helpers/debounce.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/bullet_list.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:doko_react/features/application/settings/widgets/settings_heading.dart';
import 'package:doko_react/features/authentication/presentation/widgets/error_widget.dart';
import 'package:flutter/material.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final UserGraphqlService _graphqlService = UserGraphqlService();
  final _formKey = GlobalKey<FormState>();
  final Debounce _usernameDebounce =
      Debounce(const Duration(milliseconds: 500));
  bool _loading = false;
  String _username = "";
  String _apiErrorMessage = "";
  bool _usernameAvailable = false;

  final List<String> usernamePattern = [
    "Be between 3 and 20 characters long.",
    "Start with a letter (a-z or A-Z).",
    "Contain only letters, numbers, underscores ( _ ), periods ( . ), and hyphens ( - ).",
  ];

  Future<void> _isAvailable(String username) async {
    safePrint(username);
    var usernameResponse = await _graphqlService.checkUsername(username);
    String message = "";
    bool available = true;

    if (usernameResponse.status == ResponseStatus.error) {
      message = "Oops! Something went wrong. Please try again later.";
      available = false;
    }

    if (!usernameResponse.available) {
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
              onPressed: () {},
              child: Text(
                "Sign out",
                style: TextStyle(
                  color: currTheme.error,
                ),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeading("Create username"),
            const Text(
                "Your username, is a unique identifier that allows others to find and connect with your profile. Once created, your username cannot be changed."),
            const SizedBox(
              height: 8,
            ),
            const SettingsHeading(
              "Your username must:",
              size: 14,
            ),
            BulletList(usernamePattern),
            const SizedBox(
              height: 24,
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

                            _username = value;
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
                          height: 8,
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
                    ElevatedButton(
                      onPressed: !_usernameAvailable ? null : () {} ,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 24),
                        backgroundColor: currTheme.primary,
                        foregroundColor: currTheme.onPrimary,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: _loading
                            ? const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Continue"),
                      ),
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
