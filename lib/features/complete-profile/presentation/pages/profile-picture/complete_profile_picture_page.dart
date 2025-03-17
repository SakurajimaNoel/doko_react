import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/profile-picture-selection/profile_picture_selection.dart';
import 'package:doko_react/features/authentication/presentation/widgets/public/sign-out-button/sign_out_button.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:doko_react/features/complete-profile/presentation/bloc/complete_profile_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompleteProfilePicturePage extends StatefulWidget {
  const CompleteProfilePicturePage({
    super.key,
    required this.username,
    required this.name,
    required this.dob,
  });

  final String username;
  final String name;
  final String dob;

  @override
  State<CompleteProfilePicturePage> createState() =>
      _CompleteProfilePicturePageState();
}

class _CompleteProfilePicturePageState
    extends State<CompleteProfilePicturePage> {
  String? profilePicture;

  void selectProfilePicture(String? selectedImagePath) {
    setState(() {
      profilePicture = selectedImagePath;
    });
  }

  void stateActions(BuildContext context, CompleteProfileState state) {
    if (state is CompleteProfileCompletedState) {
      // send event to userBloc
      var user = context.read<UserBloc>();
      var userState = user.state as UserIncompleteState;
      user.add(UserProfileCompleteEvent(
        username: widget.username,
        userId: userState.id,
        email: userState.email,
      ));
      return;
    }

    String errorMessage = (state as CompleteProfileErrorState).message;
    showError(errorMessage);
  }

  void handleCompleteProfile(BuildContext context) {
    var user = context.read<UserBloc>();
    var userState = user.state as UserIncompleteState;

    var completeUserDetails = CompleteProfileInput(
      userId: userState.id,
      username: widget.username,
      email: userState.email,
      profilePath: profilePicture!,
      name: widget.name,
      dob: DateTime.parse(
        widget.dob,
      ),
    );

    context.read<CompleteProfileBloc>().add(
          CompleteProfileDetailsEvent(completeUserDetails: completeUserDetails),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<CompleteProfileBloc>(),
      child: BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
        listenWhen: (previousState, state) {
          return (state is CompleteProfileErrorState ||
                  state is CompleteProfileCompletedState) &&
              previousState != state;
        },
        listener: stateActions,
        builder: (context, state) {
          bool loading = state is CompleteProfileLoadingState;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Profile Photo"),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: Constants.gap,
              ),
              actions: [
                if (!loading) const SignOutButton(),
              ],
            ),
            body: Column(
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
                                  "Profile Information",
                                  size: Constants.largeFontSize,
                                ),
                                const Text(
                                    "Almost there! Select an image to add as your profile picture."),
                                const SizedBox(
                                  height: Constants.gap,
                                ),
                                ProfilePictureSelection(
                                  key:
                                      const ValueKey("profile-image-selection"),
                                  onSelectionChange: selectProfilePicture,
                                  disabled: loading,
                                ),
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
                      onPressed: profilePicture == null || loading
                          ? null
                          : () => handleCompleteProfile(context),
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
