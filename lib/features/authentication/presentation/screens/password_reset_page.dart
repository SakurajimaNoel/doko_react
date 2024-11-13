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

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({
    super.key,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  final _formKey = GlobalKey<FormState>();
  String _email = "";
  bool _loading = false;
  String _errorMessage = "";

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

    var resetStatus = await auth.resetPassword(_email);
    if (resetStatus.status == AuthStatus.error) {
      setState(() {
        _loading = false;
        _errorMessage = resetStatus.message!;
      });
      return;
    }

    _handleResetCode();
  }

  void _handleResetCode() {
    context.pushNamed(
      RouterConstants.passwordResetConfirm,
      pathParameters: {
        "email": _email,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          children: [
            const Spacer(),
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
              child: _loading ? const LoaderButton() : const Text("Continue"),
            ),
            const SizedBox(
              height: Constants.gap,
            ),
            const Text(
              "We'll send you a verification code to your email to reset your password.",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: Constants.smallFontSize,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                text: "Need to log in? Visit ",
                style: TextStyle(
                  color: currTheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: "Login",
                    style: TextStyle(
                      color: currTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.goNamed(RouterConstants.login);
                      },
                  ),
                  const TextSpan(
                    text: " page.",
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
