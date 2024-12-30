import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
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
    if (state is AuthenticationUpdatePasswordSuccess) {
      formKey.currentState?.reset();
      String message = "Your password has been successfully updated.";
      showMessage(message);
      context.goNamed(RouterConstants.settings);
      return;
    }

    String errorMessage = (state as AuthenticationError).message;
    showMessage(errorMessage);
  }

  void handleUpdatePassword(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final updateDetails = UpdatePasswordInput(
      oldPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
    );

    context.read<AuthenticationBloc>().add(UpdatePasswordEvent(
          updateDetails: updateDetails,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: BlocProvider(
          create: (context) => serviceLocator<AuthenticationBloc>(),
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listenWhen: (previousState, state) {
              return (state is AuthenticationError ||
                      state is AuthenticationUpdatePasswordSuccess) &&
                  previousState != state;
            },
            listener: stateActions,
            builder: (context, state) {
              bool loading = state is AuthenticationLoading;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Heading.left(
                    "Update Password",
                    size: Constants.largeFontSize,
                  ),
                  const SizedBox(
                    height: Constants.gap,
                  ),
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            enabled: !loading,
                            obscureText: true,
                            controller: currentPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Current Password is required to update password.";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Current Password",
                                hintText: "Current Password..."),
                          ),
                          const SizedBox(
                            height: Constants.gap * 1.5,
                          ),
                          TextFormField(
                            enabled: !loading,
                            obscureText: true,
                            controller: newPasswordController,
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
                                hintText: "New Password..."),
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
                                      newPasswordController.text.trim(), value)
                                  ? null
                                  : "Both password should match.";
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Confirm new password",
                                hintText: "Confirm new password..."),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed:
                        loading ? null : () => handleUpdatePassword(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(
                        Constants.buttonWidth,
                        Constants.buttonHeight,
                      ),
                    ),
                    child: loading
                        ? const SmallLoadingIndicator()
                        : const Text("Update"),
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
