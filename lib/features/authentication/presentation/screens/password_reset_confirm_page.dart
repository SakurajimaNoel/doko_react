import 'package:doko_react/core/router/router_constants.dart';
import 'package:doko_react/features/authentication/presentation/widgets/heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/input.dart';
import '../../data/auth.dart';
import '../widgets/error_widget.dart';

class PasswordResetConfirmPage extends StatefulWidget {
  final String email;

  const PasswordResetConfirmPage({super.key, required this.email});

  @override
  State<PasswordResetConfirmPage> createState() => _PasswordResetConfirmPage();
}

class _PasswordResetConfirmPage extends State<PasswordResetConfirmPage> {
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

    var resetStatus = await AuthenticationActions.confirmResetPassword(
        _email, _code, _password);
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
        duration: Duration(milliseconds: 500), // Duration for the Snackbar
      ),
    );

    // Delay the navigation
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        context.goNamed(RouterConstants.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Heading(
                "Password Reset",
                size: 36,
              ),
              const SizedBox(height: 30),
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
                    const SizedBox(height: 30),
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
                          hintText: "New Password..."),
                    ),
                    const SizedBox(height: 30),
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
                          hintText: "Confirm Password..."),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 24),
                        backgroundColor: currTheme.primary,
                        foregroundColor: currTheme.onPrimary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: _loading
                            ? const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Reset"),
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
          )),
        ));
  }
}
