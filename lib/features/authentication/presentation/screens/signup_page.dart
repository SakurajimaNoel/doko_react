import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loader/loader_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({
    super.key,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  bool _loading = false;
  String _errorMessage = "";

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _loading = true;
      _errorMessage = "";
    });

    var signupStatus = await auth.signUpUser(_email, _password);

    if (signupStatus.status == AuthStatus.error) {
      setState(() {
        _loading = false;
        _errorMessage = signupStatus.message!;
      });
      return;
    }

    // send user back to login screen;
    _handleSuccess();
  }

  void _handleSuccess() {
    String message =
        "Almost there! Just one more step: verify your email address to activate your account. Look for the verification email in your inbox.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(
          milliseconds: 750,
        ),
      ),
    );
    _formKey.currentState?.reset();

    context.goNamed(RouterConstants.login);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Heading("Signup"),
            const SizedBox(
              height: Constants.gap * 1.5,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    enabled: !_loading,
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }

                      _email = value;
                    },
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
                      hintText: "Email...",
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
                      labelText: "Password",
                      hintText: "Password...",
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
                    child:
                        _loading ? const LoaderButton() : const Text("Sign Up"),
                  ),
                  const SizedBox(
                    height: Constants.gap,
                  ),
                  const Text(
                    "Once you've created your account, please check your inbox for a verification email.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: Constants.smallFontSize,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            RichText(
                text: TextSpan(
              text: "Already have the account? ",
              style: TextStyle(
                color: currTheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: "Login.",
                  style: TextStyle(
                    color: currTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.goNamed(RouterConstants.login);
                    },
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}
