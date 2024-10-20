import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loader/loader_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PasswordResetConfirmPage extends StatefulWidget {
  final String email;

  const PasswordResetConfirmPage({
    super.key,
    required this.email,
  });

  @override
  State<PasswordResetConfirmPage> createState() => _PasswordResetConfirmPage();
}

class _PasswordResetConfirmPage extends State<PasswordResetConfirmPage> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String _code = "";
  String _password = "";
  String _errorMessage = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _email = widget.email;
  }

  Future<void> _submit() async {
    bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _loading = true;
      _errorMessage = "";
    });

    var resetStatus = await auth.confirmResetPassword(_email, _code, _password);
    if (resetStatus.status == AuthStatus.error) {
      setState(() {
        _loading = false;
        _errorMessage = resetStatus.message!;
      });
      return;
    }

    _handlePasswordResetSuccess();
  }

  void _handlePasswordResetSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Password reset successful. You can now login using new password.'),
        duration: Duration(
          milliseconds: 500,
        ),
      ),
    );

    Timer(const Duration(milliseconds: 500), () {
      context.goNamed(RouterConstants.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Heading(
              "Password Reset",
              size: Constants.heading2,
            ),
            const SizedBox(
              height: Constants.gap * 1.5,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    enabled: !_loading,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }

                      _code = value;
                    },
                    validator: (value) {
                      InputStatus status =
                          ValidateInput.validateConfirmCode(value);
                      if (!status.isValid) {
                        return status.message;
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Code",
                      hintText: "Code...",
                      counterText: '',
                    ),
                  ),
                  const SizedBox(
                    height: Constants.gap * 1.5,
                  ),
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
                      hintText: "New Password...",
                    ),
                  ),
                  const SizedBox(
                    height: Constants.gap * 1.5,
                  ),
                  TextFormField(
                    enabled: !_loading,
                    obscureText: true,
                    validator: (value) {
                      InputStatus status =
                          ValidateInput.validateConfirmPassword(
                              _password, value);

                      if (!status.isValid) {
                        return status.message;
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Confirm Password",
                      hintText: "Confirm Password...",
                    ),
                  ),
                  const SizedBox(
                    height: Constants.gap * 0.5,
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(
                      height: Constants.gap * 0.75,
                    ),
                    ErrorText(_errorMessage),
                  ],
                ],
              ),
            ),
            const SizedBox(
              height: Constants.gap * 1.5,
            ),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size(
                  Constants.buttonWidth,
                  Constants.buttonHeight,
                ),
              ),
              child: _loading ? const LoaderButton() : const Text("Reset"),
            ),
            const SizedBox(
              height: Constants.gap,
            ),
            const Text(
              "We've sent a password reset code to your email. Please check your inbox (and spam folder) for the code.",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: Constants.smallFontSize,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
