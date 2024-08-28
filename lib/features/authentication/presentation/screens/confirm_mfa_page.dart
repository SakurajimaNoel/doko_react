
import 'package:doko_react/features/authentication/presentation/widgets/heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/data/auth.dart';
import '../../../../core/helpers/input.dart';
import '../widgets/error_widget.dart';

class ConfirmMfaPage extends StatefulWidget {
  const ConfirmMfaPage({super.key});

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
    ColorScheme currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 150),
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Heading("Two-factor authentication", size: 26),
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
                          : const Text("Continue"),
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
        )),
      ),
    );
  }
}
