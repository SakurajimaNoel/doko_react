import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String _password = "";
  String _newPassword = "";
  String _errorMessage = "";

  Future<void> _handleUpdate() async {
    bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();
    setState(() {
      _loading = true;
      _errorMessage = "";
    });

    var updateStatus = await auth.updatePassword(_password, _newPassword);

    if (updateStatus.status == AuthStatus.error) {
      setState(() {
        _loading = false;
        _errorMessage = updateStatus.message!;
      });
      return;
    }

    _handleSuccess();
  }

  void _handleSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your password has been successfully updated.'),
        duration: Constants.snackBarDuration,
      ),
    );

    context.goNamed(RouterConstants.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Heading(
              "Update Password",
              size: 36,
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    enabled: !_loading,
                    obscureText: true,
                    onChanged: (value) {
                      _password = value;
                    },
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }

                      _password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password can't be empty";
                      }
                      final RegExp finalPasswordRegex =
                          RegExp(r"^[\S\+.*[\S]+$");
                      if (!finalPasswordRegex.hasMatch(value)) {
                        return "Invalid password entered.";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Old Password",
                        hintText: "Old Password..."),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    enabled: !_loading,
                    obscureText: true,
                    onChanged: (value) {
                      _newPassword = value;
                    },
                    onSaved: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          _password == value) {
                        return;
                      }

                      _newPassword = value;
                    },
                    validator: (value) {
                      if (value == _password) {
                        return "The old and new passwords are identical. ";
                      }

                      InputStatus status =
                          ValidateInput.validatePassword(value);

                      if (!status.isValid) {
                        return status.message;
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "New Password",
                        hintText: "New Password..."),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    enabled: !_loading,
                    obscureText: true,
                    validator: (value) {
                      InputStatus status =
                          ValidateInput.validateConfirmPassword(
                              _newPassword, value);

                      if (!status.isValid) {
                        return status.message;
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Confirm new password",
                        hintText: "Confirm new password..."),
                  ),
                  const SizedBox(height: 30),
                  FilledButton(
                    onPressed: _loading ? null : _handleUpdate,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: _loading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Update"),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ErrorText(_errorMessage),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
