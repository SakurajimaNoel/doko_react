import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerifyMfaPage extends StatefulWidget {
  const VerifyMfaPage({super.key});

  @override
  State<VerifyMfaPage> createState() => _VerifyMfaPageState();
}

class _VerifyMfaPageState extends State<VerifyMfaPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void stateActions(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationVerifyMFASuccess) {
      // update status
      context.read<UserBloc>().add(UserUpdateMFAEvent(
            mfaStatus: true,
          ));
      showSuccess('Successfully added MFA to this account!');
      context.goNamed(RouterConstants.settings);
      return;
    }

    String errorMessage = (state as AuthenticationError).message;
    showError(errorMessage);
  }

  void handleVerifyMFA(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    context.read<AuthenticationBloc>().add(VerifyMFAEvent(
          code: controller.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete MFA setup"),
      ),
      body: CompactBox(
        child: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: BlocProvider(
            create: (context) => serviceLocator<AuthenticationBloc>(),
            child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
              listenWhen: (previousState, state) {
                return (state is AuthenticationError ||
                        state is AuthenticationVerifyMFASuccess) &&
                    previousState != state;
              },
              listener: stateActions,
              builder: (context, state) {
                bool loading = state is AuthenticationLoading;

                return Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                              "Enter the code from your authenticator app to complete the MFA setup and strengthen your account security."),
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
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed:
                          loading ? null : () => handleVerifyMFA(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          Constants.buttonWidth,
                          Constants.buttonHeight,
                        ),
                      ),
                      child: loading
                          ? const LoadingWidget.small()
                          : const Text("Complete"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
