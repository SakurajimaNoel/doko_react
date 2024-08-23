import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/input.dart';
import '../../../authentication/data/auth.dart';
import '../../../authentication/presentation/widgets/error_widget.dart';

class VerifyMfaPage extends StatefulWidget {
  const VerifyMfaPage({super.key});

  @override
  State<VerifyMfaPage> createState() => _VerifyMfaPage();
}

class _VerifyMfaPage extends State<VerifyMfaPage> {
  static const double _padding = 16;
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
    // Show the Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully added MFA to this account!'),
        duration: Duration(milliseconds: 500), // Duration for the Snackbar
      ),
    );

    // Delay the navigation
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        context.goNamed(
          RouterConstants.settings,
          extra: {
            "clearStack": true,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            children: [
              const Text(
                  "Enter the code from your authenticator app to complete the MFA setup and strengthen your account security."),
              const SizedBox(height: 30),
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
                            : const Text("Complete"),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ErrorText(_errorMessage),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
