import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/features/authentication/presentation/widgets/error_widget.dart';
import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:doko_react/features/authentication/presentation/screens/confirm_mfa_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/password_reset_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/signup_page.dart';
import 'package:doko_react/features/authentication/presentation/widgets/heading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  String _email = "";
  String _password = "";
  bool _loading = false;
  String _errorMessage = "";

  void _submit() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _loading = true;
      _errorMessage = "";
    });
    var loginStatus = await AuthenticationActions.signInUser(_email, _password);
    if (loginStatus.status == AuthStatus.error) {
      setState(() {
        _loading = false;
        _errorMessage = loginStatus.message!;
      });
    }

    if (loginStatus.status == AuthStatus.confirmMFA) {
      _handleMfa();
    }
  }

  void _handleMfa() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ConfirmMfaPage()));
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Heading("Login"),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    enabled: !_loading,
                    validator: (value) {
                      InputStatus status = ValidateInput.validateEmail(value);
                      if (!status.isValid) {
                        return status.message;
                      }

                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email",
                        hintText: "Email..."),
                    onSaved: (value) {
                      if (value == null || value.isEmpty) return;
                      _email = value;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_loading,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password can't be empty";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                      hintText: "Password...",
                    ),
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }

                      _password = value;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
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
                          : const Text("Login"),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ErrorText(_errorMessage),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PasswordResetPage()));
                    },
              style: TextButton.styleFrom(foregroundColor: currTheme.secondary),
              child: const Text("Forgot Password?"),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RichText(
                  text: TextSpan(
                text: "Don't have the account? ",
                style: TextStyle(color: currTheme.onSurface),
                children: [
                  TextSpan(
                      text: "Sign Up.",
                      style: TextStyle(
                          color: currTheme.primary,
                          fontWeight: FontWeight.w500),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _loading
                            ? null
                            : () async {
                                final Map<String, String>? result =
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignupPage()));

                                if (!context.mounted) return;
                                if (result == null) {
                                  return;
                                }

                                setState(() {
                                  _emailController.text = result["email"]!;
                                  _passwordController.text =
                                      result["password"]!;
                                });

                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                      content: Text(
                                    result["message"]!,
                                    textAlign: TextAlign.center,
                                  )));
                              })
                ],
              )),
            ),
          ],
        ),
      ),
    ));
  }
}
