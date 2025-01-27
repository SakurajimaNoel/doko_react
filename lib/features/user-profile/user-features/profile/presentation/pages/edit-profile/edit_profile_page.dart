import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/utils/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/image-picker/image_picker_widget.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController bioController;

  late final CompleteUserEntity user;

  /// make it null when removing profile picture
  /// when profile is present it will be either
  /// current profile bucket path
  /// or path to new profile picture
  String? newProfilePicture;

  @override
  void initState() {
    super.initState();

    String username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    UserGraph graph = UserGraph();
    String key = generateUserNodeKey(username);

    user = graph.getValueByKey(key)! as CompleteUserEntity;

    nameController = TextEditingController(
      text: user.name,
    );
    bioController = TextEditingController(
      text: user.bio,
    );
    newProfilePicture = user.profilePicture.bucketPath;
  }

  void stateActions(BuildContext context, ProfileState state) {
    if (state is ProfileEditSuccess) {
      showSuccess(context, 'Successfully updated user profile');

      UserGraph graph = UserGraph();
      String key = generateUserNodeKey(user.username);

      final tempUser = graph.getValueByKey(key)! as CompleteUserEntity;
      context.read<UserActionBloc>().add(UserActionUpdateEvent(
            name: tempUser.name,
            bio: tempUser.bio,
            profilePicture: tempUser.profilePicture.bucketPath,
          ));

      context.pop();
      return;
    }

    String errorMessage = (state as ProfileError).message;
    showError(context, errorMessage);
  }

  bool needsUpdate() {
    if (user.name.trim() != nameController.text.trim()) return true;
    if (user.bio.trim() != bioController.text.trim()) return true;

    if (user.profilePicture.bucketPath != newProfilePicture) return true;

    return false;
  }

  void handleEditProfile(BuildContext context) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    if (!needsUpdate()) {
      context.pop();
      return;
    }

    EditProfileInput editDetails = EditProfileInput(
      username: user.username,
      userId: user.userId,
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      currentProfile: user.profilePicture.bucketPath,
      newProfile: newProfilePicture,
    );

    context.read<ProfileBloc>().add(EditUserProfileEvent(
          editDetails: editDetails,
        ));
  }

  void setProfilePicture(String? path) {
    newProfilePicture = path;
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<ProfileBloc>(),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previousState, state) {
          return state is ProfileEditSuccess || state is ProfileError;
        },
        listener: stateActions,
        builder: (context, state) {
          bool updating = state is ProfileLoading;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Edit profile"),
              actions: [
                TextButton(
                  onPressed: updating ? null : () => handleEditProfile(context),
                  child: updating
                      ? const SmallLoadingIndicator.small()
                      : const Text("Save"),
                ),
              ],
            ),
            body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (bool didPop, var result) {
                if (didPop || updating) return;

                context.pop();
              },
              child: ListView(
                padding: const EdgeInsets.all(Constants.padding),
                children: [
                  _ProfileSelection(
                    key: const ValueKey("profile-picture"),
                    setProfile: setProfilePicture,
                    updating: updating,
                    currentProfile: user.profilePicture,
                  ),
                  const SizedBox(
                    height: Constants.gap * 2,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          enabled: !updating,
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Name",
                            hintText: "Name...",
                          ),
                          maxLength: 30,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(
                          height: Constants.gap,
                        ),
                        TextFormField(
                          enabled: !updating,
                          controller: bioController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Bio",
                            hintText: "Bio...",
                          ),
                          validator: (value) {
                            return validateBio(value) ? null : "Invalid bio";
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 5,
                          maxLength: 160,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ],
                    ),
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

class _ProfileSelection extends StatefulWidget {
  const _ProfileSelection({
    super.key,
    required this.setProfile,
    required this.updating,
    required this.currentProfile,
  });

  final ValueSetter<String?> setProfile;
  final bool updating;
  final StorageResource currentProfile;

  @override
  State<_ProfileSelection> createState() => _ProfileSelectionState();
}

class _ProfileSelectionState extends State<_ProfileSelection> {
  String? newProfilePicture;
  bool removeProfile = false;

  Future<bool> checkAnimatedImage(String path) async {
    String? extension = getFileExtensionFromFileName(path);

    if (extension == ".gif") return true;
    if (extension == ".webp") return await isWebpAnimated(path);

    return false;
  }

  Future<void> onSelection(List<XFile> images) async {
    XFile selectedImage = images.first;
    removeProfile = false;

    // check if selected image is animated or not
    if (await checkAnimatedImage(selectedImage.path)) {
      setState(() {
        newProfilePicture = selectedImage.path;
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
      newProfilePicture = croppedImage.path;
    });
  }

  void handleRemove() {
    newProfilePicture = null;
    widget.setProfile(null);

    removeProfile = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    final width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    final height = width * (1 / Constants.profile);

    bool noPicture = removeProfile ||
        (widget.currentProfile.bucketPath.isEmpty && newProfilePicture == null);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          getProfileImage(height),
          ProfilePictureFilter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ImagePickerWidget(
                  onSelection: onSelection,
                  icon: const Icon(Icons.photo_camera),
                  disabled: widget.updating,
                ),
                if (!noPicture)
                  IconButton.filled(
                    onPressed: widget.updating ? null : handleRemove,
                    icon: const Icon(Icons.delete),
                    color: currTheme.onError,
                    style: IconButton.styleFrom(
                      backgroundColor: currTheme.error,
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getProfileImage(double height) {
    final currTheme = Theme.of(context).colorScheme;

    if (removeProfile ||
        (widget.currentProfile.bucketPath.isEmpty &&
            newProfilePicture == null)) {
      return Container(
        color: currTheme.surfaceContainerHighest,
        child: const Icon(
          Icons.person,
          size: Constants.height * 15,
        ),
      );
    }

    if (newProfilePicture != null) {
      return Image.file(
        File(newProfilePicture!),
        fit: BoxFit.cover,
        cacheHeight: Constants.editProfileCachedHeight,
      );
    }

    return CachedNetworkImage(
      memCacheHeight: Constants.profileCacheHeight,
      cacheKey: widget.currentProfile.bucketPath,
      imageUrl: widget.currentProfile.accessURI,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: SmallLoadingIndicator.small(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      height: height,
    );
  }
}
