import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/archive/core/data/auth.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/input.dart';
import 'package:doko_react/archive/core/widgets/error/error_text.dart';
import 'package:doko_react/archive/core/widgets/heading/heading.dart';
import 'package:doko_react/archive/core/widgets/loader/loader_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmMfaPage extends StatefulWidget {
  const ConfirmMfaPage({
    super.key,
  });

  @override
  State<ConfirmMfaPage> createState() => _ConfirmMfaPageState();
}

class _ConfirmMfaPageState extends State<ConfirmMfaPage> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  final _formKey = GlobalKey<FormState>();
  String _confirmString = "";
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

    var confirmStatus = await auth.confirmSignInUser(_confirmString);

    if (confirmStatus.status == AuthStatus.error) {
      setState(() {
        _loading = false;
        _errorMessage = confirmStatus.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Heading(
              "Multi-factor authentication",
              size: Constants.heading3,
            ),
            const SizedBox(
              height: Constants.gap * 1.5,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enabled: !_loading,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Code",
                      hintText: "Code...",
                    ),
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }
                      _confirmString = value;
                    },
                    validator: (value) {
                      InputStatus status =
                          ValidateInput.validateConfirmCode(value);
                      if (!status.isValid) {
                        return status.message;
                      }

                      return null;
                    },
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
              "Check your authenticator app for the code to verify your identity.",
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
