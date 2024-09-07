import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/loader_button.dart';
import 'package:doko_react/features/authentication/presentation/widgets/heading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/auth.dart';
import '../../../../core/helpers/constants.dart';
import '../widgets/error_widget.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({
    super.key,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
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

    var resetStatus = await AuthenticationActions.resetPassword(_email);
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
    context.goNamed(
      RouterConstants.passwordResetConfirm,
      pathParameters: {
        "email": _email,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
