import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void stateActions(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationResetPasswordSuccess) {
      context.pushNamed(
        RouterConstants.confirmPasswordReset,
        pathParameters: {
          "email": emailController.text.trim(),
        },
      );
      return;
    }

    String errorMessage = (state as AuthenticationError).message;
    showError(errorMessage);
  }

  void handleResetPassword(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final resetPasswordDetails = ResetPasswordInput(
      email: emailController.text.trim(),
    );
    context.read<AuthenticationBloc>().add(
          ResetPasswordEvent(
            resetDetails: resetPasswordDetails,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => serviceLocator<AuthenticationBloc>(),
        child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listenWhen: (previousState, state) {
            return (state is AuthenticationResetPasswordSuccess ||
                    state is AuthenticationError) &&
                previousState != state;
          },
          listener: stateActions,
          builder: (context, state) {
            bool loading = state is AuthenticationLoading;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
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
                                      controller: emailController,
                                      enabled: !loading,
                                      validator: (value) {
                                        return validateEmail(value)
                                            ? null
                                            : "Invalid email";
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Email",
                                        hintText: "Email...",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Constants.gap * 0.5,
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
                                    : () => handleResetPassword(context),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(
                                    Constants.buttonWidth,
                                    Constants.buttonHeight,
                                  ),
                                ),
                                child: loading
                                    ? const SmallLoadingIndicator()
                                    : const Text("Continue"),
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Constants.padding),
                  child: Center(
                    child: RichText(
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
                              ..onTap = loading
                                  ? null
                                  : () {
                                      context.goNamed(RouterConstants.login);
                                    },
                          ),
                          const TextSpan(
                            text: " page.",
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
