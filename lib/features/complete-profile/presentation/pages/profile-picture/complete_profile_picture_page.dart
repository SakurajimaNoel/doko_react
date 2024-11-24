import 'dart:io';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/image-picker/image_picker_widget.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
import 'package:doko_react/features/authentication/presentation/widgets/public/sign-out-button/sign_out_button.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:doko_react/features/complete-profile/presentation/bloc/complete_profile_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  void selectProfilePicture(String selectedImagePath) {
    setState(() {
      profilePicture = selectedImagePath;
    });
  }

  void stateActions(BuildContext context, CompleteProfileState state) {
    if (state is CompleteProfileCompletedState) {
      // send event to userbloc
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
    showMessage(errorMessage);
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
              actions: [
                if (!loading) const SignOutButton(),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(Constants.padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                        _ImageSelection(
                          key: const ValueKey("profile-image-selection"),
                          setProfile: selectProfilePicture,
                          loading: loading,
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
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
                        ? const SmallLoadingIndicator()
                        : const Text("Complete"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageSelection extends StatefulWidget {
  const _ImageSelection({
    super.key,
    required this.setProfile,
    required this.loading,
  });

  final ValueSetter<String> setProfile;
  final bool loading;

  @override
  State<_ImageSelection> createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<_ImageSelection> {
  String? profilePicture;

  Future<bool> checkAnimatedImage(String path) async {
    String? extension = getFileExtensionFromFileName(path);

    if (extension == ".gif") return true;
    if (extension == ".webp") return await isWebpAnimated(path);

    return false;
  }

  Future<void> onSelection(List<XFile> images) async {
    XFile selectedImage = images.first;

    // check if selected image is animated or not
    if (await checkAnimatedImage(selectedImage.path)) {
      setState(() {
        profilePicture = selectedImage.path;
      });
      return;
    }

    if (!mounted) return;
    CroppedFile? croppedImage = await getCroppedImage(
      selectedImage.path,
      context: context,
      location: ImageLocation.profile,
    );

    if (croppedImage == null) return;
    widget.setProfile(croppedImage.path);
    setState(() {
      profilePicture = croppedImage.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    final height = width * (1 / Constants.profile);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          getProfileImage(),
          ProfilePictureFilter(
            child: ImagePickerWidget(
              disabled: widget.loading,
              onSelection: onSelection,
              icon: const Icon(Icons.photo_camera),
            ),
          )
        ],
      ),
    );
  }

  Widget getProfileImage() {
    final currTheme = Theme.of(context).colorScheme;

    if (profilePicture == null) {
      return Container(
        color: currTheme.surfaceContainerHighest,
        child: const Icon(
          Icons.person,
          size: Constants.height * 15,
        ),
      );
    }

    return Image.file(
      File(profilePicture!),
      fit: BoxFit.cover,
      cacheHeight: Constants.editProfileCachedHeight,
    );
  }
}
