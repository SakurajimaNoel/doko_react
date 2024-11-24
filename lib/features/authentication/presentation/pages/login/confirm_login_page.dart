import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmLoginPage extends StatefulWidget {
  const ConfirmLoginPage({super.key});

  @override
  State<ConfirmLoginPage> createState() => _ConfirmLoginPageState();
}

class _ConfirmLoginPageState extends State<ConfirmLoginPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  void stateActions(BuildContext context, AuthenticationState state) {
    String errorMessage = (state as AuthenticationError).message;
    showMessage(errorMessage);
  }

  void handleConfirmLogin(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.read<AuthenticationBloc>().add(ConfirmLoginEvent(
          code: controller.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: BlocProvider(
          create: (context) => serviceLocator<AuthenticationBloc>(),
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previousState, state) {
              return state is AuthenticationError && previousState != state;
            },
            listener: stateActions,
            builder: (context, state) {
              bool loading = state is AuthenticationLoading;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Heading(
                    "Multi-factor authentication",
                    size: Constants.heading3,
                  ),
                  const SizedBox(
                    height: Constants.gap * 1.5,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          enabled: !loading,
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
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length > 6) {
                              return "Invalid code.";
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: Constants.gap,
                  ),
                  FilledButton(
                    onPressed:
                        loading ? null : () => handleConfirmLogin(context),
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
                    "Check your authenticator app for the code to verify your identity.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: Constants.smallFontSize,
                      fontStyle: FontStyle.italic,
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
