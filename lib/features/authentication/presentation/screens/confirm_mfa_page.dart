import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/widgets/heading.dart';
import 'package:doko_react/core/widgets/loader_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/data/auth.dart';
import '../../../../core/helpers/input.dart';
import '../../../../core/widgets/error_text.dart';

class ConfirmMfaPage extends StatefulWidget {
  const ConfirmMfaPage({
    super.key,
  });

  @override
  State<ConfirmMfaPage> createState() => _ConfirmMfaPageState();
}

class _ConfirmMfaPageState extends State<ConfirmMfaPage> {
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

    var confirmStatus =
        await AuthenticationActions.confirmSignInUser(_confirmString);

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
        padding: const EdgeInsets.only(
          left: Constants.gap,
          right: Constants.gap,
          top: Constants.gap * 10,
        ),
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Heading(
              "Two-factor authentication",
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
                  const SizedBox(height: Constants.gap * 1.5),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(
                        Constants.buttonWidth,
                        Constants.buttonHeight,
                      ),
                    ),
                    child: _loading
                        ? const LoaderButton()
                        : const Text("Continue"),
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
          ],
        )),
      ),
    );
  }
}
