import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/bullet-list/bullet_list.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/authentication/presentation/widgets/public/sign-out-button/sign_out_button.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:doko_react/features/complete-profile/presentation/bloc/complete_profile_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompleteProfileUsernamePage extends StatefulWidget {
  const CompleteProfileUsernamePage({super.key});

  @override
  State<CompleteProfileUsernamePage> createState() =>
      _CompleteProfileUsernamePageState();
}

class _CompleteProfileUsernamePageState
    extends State<CompleteProfileUsernamePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  final List<String> usernamePattern = [
    "Be between 3 and ${Constants.usernameLimit} characters long.",
    "Start with a letter (a-z or A-Z).",
    "Contain only letters, numbers, underscores ( _ ), periods ( . ), and hyphens ( - ).",
  ];

  void stateActions(BuildContext context, CompleteProfileState state) {
    String errorMessage = (state as CompleteProfileErrorState).message;
    showError(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
        actions: const [
          SignOutButton(),
        ],
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<CompleteProfileBloc>(),
        child: BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
          listenWhen: (previousState, state) {
            return state is CompleteProfileErrorState && previousState != state;
          },
          listener: stateActions,
          builder: (context, state) {
            bool loading = state is CompleteProfileLoadingState;
            bool valid = false;
            if (state is CompleteProfileUsernameStatusState) {
              valid = state.available &&
                  usernameController.text.trim() == state.username;
            }

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Heading.left(
                                  "Create Username",
                                  size: Constants.largeFontSize,
                                ),
                                const Text(
                                    "Your username, is a unique identifier that allows others to find and connect with your profile. Once created, your username cannot be changed."),
                                const SizedBox(
                                  height: Constants.gap * 0.5,
                                ),
                                const Heading.left(
                                  "Your username must:",
                                  size: Constants.fontSize,
                                ),
                                BulletList(usernamePattern),
                                const SizedBox(
                                  height: Constants.gap * 1.5,
                                ),
                                Form(
                                  key: formKey,
                                  child: TextFormField(
                                    controller: usernameController,
                                    validator: (value) {
                                      return validateUsername(value)
                                          ? null
                                          : "Invalid username.";
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onChanged: (value) {
                                      if (!validateUsername(value)) return;

                                      // emit username events
                                      UsernameInput input =
                                          UsernameInput(username: value);
                                      context.read<CompleteProfileBloc>().add(
                                            CompleteProfileUsernameEvent(
                                              usernameInput: input,
                                            ),
                                          );
                                    },
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "Username",
                                      hintText: "Username...",
                                      suffixIcon: loading
                                          ? const LoadingWidget.small()
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Constants.gap * 0.5,
                                ),
                                if (state is CompleteProfileUsernameStatusState)
                                  state.available
                                      ? StyledText.success(
                                          state.createDisplayMessage())
                                      : StyledText.error(
                                          state.createDisplayMessage()),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                CompactBox(
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.padding),
                    child: FilledButton(
                      onPressed: (loading || !valid)
                          ? null
                          : () {
                              if (state
                                      is! CompleteProfileUsernameStatusState ||
                                  (!state.available &&
                                      usernameController.text.trim() !=
                                          state.username)) {
                                return;
                              }

                              context.pushNamed(
                                RouterConstants.completeProfileInfo,
                                pathParameters: {
                                  "username": state.username,
                                },
                              );
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          Constants.buttonWidth,
                          Constants.buttonHeight,
                        ),
                      ),
                      child: const Text("Continue"),
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
