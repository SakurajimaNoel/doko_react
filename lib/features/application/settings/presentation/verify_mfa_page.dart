import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/core/widgets/loader/loader_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class VerifyMfaPage extends StatefulWidget {
  const VerifyMfaPage({
    super.key,
  });

  @override
  State<VerifyMfaPage> createState() => _VerifyMfaPage();
}

class _VerifyMfaPage extends State<VerifyMfaPage> {
  final _formKey = GlobalKey<FormState>();
  String _confirmString = "";
  bool _loading = false;
  String _errorMessage = "";
  late final AuthenticationProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthenticationProvider>();
  }

  Future<void> _submit() async {
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
        await AuthenticationActions.verifyMfaSetup(_confirmString);

    if (confirmStatus.status == AuthStatus.error) {
      setState(() {
        _loading = false;
        _errorMessage = confirmStatus.message!;
      });
      return;
    }

    _handleSuccess();
  }

  void _handleSuccess() {
    // Show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully added MFA to this account!'),
        duration: Duration(
          milliseconds: 500,
        ),
      ),
    );

    _authProvider.setMFAStatus(AuthenticationMFAStatus.setUpped);

    // Delay the navigation
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        context.goNamed(
          RouterConstants.settings,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SettingsHeading(
          "MFA Setup",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          children: [
            const Text(
                "Enter the code from your authenticator app to complete the MFA setup and strengthen your account security."),
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
                        : const Text("Complete"),
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
        ),
      ),
    );
  }
}
