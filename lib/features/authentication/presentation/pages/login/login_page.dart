import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/authentication/domain/entities/login/login_entity.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void stateActions(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationLoginSuccess) {
      LoginStatus status = state.status;
      formKey.currentState?.reset();

      switch (status) {
        case LoginStatus.done:
          // handled by amplify event listener
          return;
        case LoginStatus.confirmMfa:
          context.pushNamed(RouterConstants.confirmLogin);
          return;
        case LoginStatus.confirmSingUp:
          String message =
              "A verification email has been sent to your inbox.\nPlease click the link to confirm your email address and log in.";
          showInfo(message);
          return;
      }
    }

    String errorMessage = (state as AuthenticationError).message;
    showError(errorMessage);
  }

  void handleLogin(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final loginDetails = LoginInput(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    context.read<AuthenticationBloc>().add(
          LoginEvent(
            loginDetails: loginDetails,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => serviceLocator<AuthenticationBloc>(),
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previousState, state) {
              return (state is AuthenticationError ||
                      state is AuthenticationLoginSuccess) &&
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
                          child: CompactBox(
                            child: Container(
                              padding: const EdgeInsets.all(Constants.padding),
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Heading("Login"),
                                  const SizedBox(
                                    height: Constants.gap * 1.5,
                                  ),
                                  Form(
                                    key: formKey,
                                    child: AutofillGroup(
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: emailController,
                                            enabled: !loading,
                                            autofillHints: [
                                              AutofillHints.email,
                                              AutofillHints.username,
                                            ],
                                            validator: (value) {
                                              return validateEmail(value)
                                                  ? null
                                                  : "Invalid email address.";
                                            },
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
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
                                            autofillHints: [
                                              AutofillHints.password,
                                            ],
                                            controller: passwordController,
                                            enabled: !loading,
                                            obscureText: !showPassword,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Password can't be empty";
                                              }
                                              return null;
                                            },
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            decoration: InputDecoration(
                                              border:
                                                  const OutlineInputBorder(),
                                              labelText: "Password",
                                              hintText: "Password...",
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    showPassword =
                                                        !showPassword;
                                                  });
                                                },
                                                icon: showPassword
                                                    ? const Icon(
                                                        Icons.visibility)
                                                    : const Icon(
                                                        Icons.visibility_off),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: Constants.gap * 1.5,
                                          ),
                                          FilledButton(
                                            onPressed: loading
                                                ? null
                                                : () => handleLogin(context),
                                            style: FilledButton.styleFrom(
                                              minimumSize: const Size(
                                                Constants.buttonWidth,
                                                Constants.buttonHeight,
                                              ),
                                            ),
                                            child: loading
                                                ? const SmallLoadingIndicator()
                                                : const Text("Login"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Constants.gap * 0.75,
                                  ),
                                  TextButton(
                                    onPressed: loading
                                        ? null
                                        : () {
                                            context.pushNamed(
                                                RouterConstants.passwordReset);
                                          },
                                    style: TextButton.styleFrom(
                                      foregroundColor: currTheme.secondary,
                                    ),
                                    child: const Text("Forgot Password?"),
                                  ),
                                ],
                              ),
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
                          text: "Don't have the account? ",
                          style: TextStyle(
                            color: currTheme.onSurface,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign Up.",
                              style: TextStyle(
                                color: currTheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = loading
                                    ? null
                                    : () {
                                        context
                                            .pushNamed(RouterConstants.signUp);
                                      },
                            ),
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
      ),
    );
  }
}
