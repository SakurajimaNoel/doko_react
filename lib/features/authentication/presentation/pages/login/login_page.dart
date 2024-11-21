import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: BlocProvider(
          create: (context) => AuthenticationBloc(),
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previousState, state) {
              return state is AuthenticationError && previousState != state;
            },
            listener: (BuildContext context, AuthenticationState state) {
              String errorMessage = (state as AuthenticationError).message;
              showMessage(errorMessage);
            },
            builder: (context, state) {
              bool loading = state is AuthenticationLoading;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: Constants.heading1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: Constants.gap * 1.5,
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
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
                                enabled: !loading,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password can't be empty";
                                  }
                                  return null;
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
                              FilledButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                        final isValid =
                                            formKey.currentState?.validate() ??
                                                false;
                                        if (!isValid) {
                                          return;
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(
                                    Constants.buttonWidth,
                                    Constants.buttonHeight,
                                  ),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: Constants.height * 1.5,
                                        width: Constants.height * 1.5,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Text("Login"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: Constants.gap * 0.75,
                        ),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  context
                                      .pushNamed(RouterConstants.passwordReset);
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: currTheme.secondary,
                          ),
                          child: const Text("Forgot Password?"),
                        ),
                      ],
                    ),
                  ),
                  Center(
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
                                      context.pushNamed(RouterConstants.signUp);
                                    },
                          ),
                        ],
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
