import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ConfirmResetPasswordPage extends StatefulWidget {
  const ConfirmResetPasswordPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<ConfirmResetPasswordPage> createState() =>
      _ConfirmResetPasswordPageState();
}

class _ConfirmResetPasswordPageState extends State<ConfirmResetPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void stateActions(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationConfirmResetPasswordSuccess) {
      context.goNamed(
        RouterConstants.login,
      );
      return;
    }

    String errorMessage = (state as AuthenticationError).message;
    showError(errorMessage);
  }

  void handleConfirmResetPassword(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final resetPasswordDetails = ConfirmResetPasswordInput(
      email: widget.email,
      password: passwordController.text.trim(),
      code: codeController.text.trim(),
    );
    context.read<AuthenticationBloc>().add(
          ConfirmResetPasswordEvent(
            resetDetails: resetPasswordDetails,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => serviceLocator<AuthenticationBloc>(),
        child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listenWhen: (previousState, state) {
            return (state is AuthenticationConfirmResetPasswordSuccess ||
                    state is AuthenticationError) &&
                previousState != state;
          },
          listener: stateActions,
          builder: (context, state) {
            bool loading = state is AuthenticationLoading;

            return LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(Constants.padding),
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Heading(
                        "Password Reset",
                        size: Constants.heading2,
                      ),
                      const SizedBox(
                        height: Constants.gap * 1.5,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: codeController,
                              enabled: !loading,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length > 6) {
                                  return "Invalid code.";
                                }

                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Code",
                                hintText: "Code...",
                                counterText: '',
                              ),
                            ),
                            const SizedBox(
                              height: Constants.gap * 1.5,
                            ),
                            TextFormField(
                              controller: passwordController,
                              enabled: !loading,
                              obscureText: true,
                              validator: (value) {
                                return validatePassword(value)
                                    ? null
                                    : passwordInvalidateReason(value);
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "New Password",
                                hintText: "New Password...",
                              ),
                            ),
                            const SizedBox(
                              height: Constants.gap * 1.5,
                            ),
                            TextFormField(
                              enabled: !loading,
                              obscureText: true,
                              validator: (value) {
                                if (value == null) return "Invalid value.";

                                return compareString(
                                        passwordController.text.trim(), value)
                                    ? null
                                    : "Both password should match.";
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Confirm Password",
                                hintText: "Confirm Password...",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: Constants.gap * 1.5,
                      ),
                      FilledButton(
                        onPressed: loading
                            ? null
                            : () => handleConfirmResetPassword(context),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            Constants.buttonWidth,
                            Constants.buttonHeight,
                          ),
                        ),
                        child: loading
                            ? const SmallLoadingIndicator()
                            : const Text("Reset"),
                      ),
                      const SizedBox(
                        height: Constants.gap,
                      ),
                      const Text(
                        "We've sent a password reset code to your email. Please check your inbox (and spam folder) for the code.",
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
            });
          },
        ),
      ),
    );
  }
}
