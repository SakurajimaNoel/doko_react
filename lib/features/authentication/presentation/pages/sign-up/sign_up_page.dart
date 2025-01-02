import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  void stateActions(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationSignUpSuccess) {
      formKey.currentState?.reset();
      String message =
          "Almost there! Just one more step: verify your email address to activate your account. Look for the verification email in your inbox.";
      showMessage(message);
      context.goNamed(RouterConstants.login);
      return;
    }

    String errorMessage = (state as AuthenticationError).message;
    showMessage(errorMessage);
  }

  void handleSignUp(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final signupDetails = SignupInput(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    context.read<AuthenticationBloc>().add(
          SignupEvent(
            signupDetails: signupDetails,
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
            return (state is AuthenticationError ||
                    state is AuthenticationSignUpSuccess) &&
                previousState != state;
          },
          listener: stateActions,
          builder: (context, state) {
            bool loading = state is AuthenticationLoading;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(Constants.padding),
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Heading("Signup"),
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
                                          : "Invalid email address.";
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
                                      labelText: "Password",
                                      hintText: "Password...",
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Constants.gap * 1.5,
                                  ),
                                  TextFormField(
                                    enabled: !loading,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null)
                                        return "Invalid value.";

                                      return compareString(
                                              passwordController.text.trim(),
                                              value)
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
                                  const SizedBox(
                                    height: Constants.gap * 1.5,
                                  ),
                                  FilledButton(
                                    onPressed: loading
                                        ? null
                                        : () => handleSignUp(context),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(
                                        Constants.buttonWidth,
                                        Constants.buttonHeight,
                                      ),
                                    ),
                                    child: loading
                                        ? const SmallLoadingIndicator()
                                        : const Text("Sign Up"),
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
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(Constants.padding),
                  child: Center(
                    child: RichText(
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
                              ..onTap = loading
                                  ? null
                                  : () {
                                      context.goNamed(RouterConstants.login);
                                    },
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
