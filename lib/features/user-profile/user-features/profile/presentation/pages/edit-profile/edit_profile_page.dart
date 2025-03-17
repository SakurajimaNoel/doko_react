import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/profile-picture-selection/profile_picture_selection.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      showSuccess('Successfully updated user profile');

      UserGraph graph = UserGraph();
      String key = generateUserNodeKey(user.username);

      final tempUser = graph.getValueByKey(key)! as CompleteUserEntity;
      context.read<UserToUserActionBloc>().add(UserToUserUpdateProfileEvent(
            username: user.username,
            name: tempUser.name,
            bio: tempUser.bio,
            profilePicture: tempUser.profilePicture.bucketPath,
          ));

      // send to remote users
      final client = context.read<WebsocketClientProvider>().client;
      if (client != null && client.isActive) {
        // ignore if client is null
        UserUpdateProfile payload = UserUpdateProfile(
          from: user.username,
          bio: tempUser.bio,
          name: tempUser.name,
          profilePicture: tempUser.profilePicture.bucketPath,
        );
        client.sendPayload(payload);
      }

      context.pop();
      return;
    }

    String errorMessage = (state as ProfileError).message;
    showError(errorMessage);
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
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: Constants.gap,
              ),
              actions: [
                TextButton(
                  onPressed: updating ? null : () => handleEditProfile(context),
                  child: updating
                      ? const LoadingWidget.small()
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
                  CompactBox(
                    child: ProfilePictureSelection(
                      key: const ValueKey("profile-picture"),
                      onSelectionChange: setProfilePicture,
                      disabled: updating,
                      currentProfile: user.profilePicture,
                    ),
                  ),
                  const SizedBox(
                    height: Constants.gap * 2,
                  ),
                  CompactBox(
                    child: Form(
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
                            maxLength: Constants.nameLimit,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                            maxLength: Constants.bioLimit,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ],
                      ),
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
