import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/data/image_cropper.dart';
import 'package:doko_react/core/data/storage.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/image_picker/image_picker_widget.dart';
import 'package:doko_react/core/widgets/loader/loader_button.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String bio;

  const EditProfilePage({
    super.key,
    required this.bio,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final StorageActions storage = StorageActions(storage: Amplify.Storage);

  late final String _currentUserBio;
  late final UserProvider _userProvider;

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  bool _updating = false;
  bool _removeProfile = false;
  String _errorMessage = "";
  XFile? _profilePicture;

  @override
  void initState() {
    super.initState();

    _currentUserBio = widget.bio;
    _userProvider = context.read<UserProvider>();

    _nameController = TextEditingController(
      text: _userProvider.name,
    );
    _bioController = TextEditingController(
      text: _currentUserBio,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Future<void> _updateUserProfile() async {
    bool validate = _formKey.currentState?.validate() ?? false;
    if (!validate) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _updating = true;
      _errorMessage = "";
    });

    String id = _userProvider.id;
    String name = _nameController.text;
    String bio = _bioController.text;
    String bucketPath = _userProvider.profilePicture;

    // when new profile picture is selected
    if (!_removeProfile && _profilePicture != null) {
      String? imageExtension =
          MediaType.getExtensionFromFileName(_profilePicture!.path);

      if (imageExtension == null) {
        setState(() {
          _errorMessage = "Invalid image file selected.";
          _updating = false;
        });
        return;
      }

      String imageString = DisplayText.generateRandomString();
      bucketPath = "$id/profile/$imageString$imageExtension";

      var imageResult = await _handleImage(bucketPath);
      if (!imageResult) {
        setState(() {
          _errorMessage = "Error uploading profile image.";
          _updating = false;
        });
        return;
      }

      storage.deleteFile(_userProvider.profilePicture);
    }

    // when profile picture is removed
    if (_removeProfile) {
      storage.deleteFile(_userProvider.profilePicture);
      bucketPath = "";
    }

    // update graph
    var updateResult =
        await _userGraphqlService.updateUserProfile(id, name, bio, bucketPath);

    if (updateResult.status == ResponseStatus.error) {
      String message =
          "Updated user profile image. Error updating other fields.";

      if (_profilePicture == null) {
        message = "Error updating user profile fields.";
      }

      setState(() {
        _errorMessage = message;
        _updating = false;
      });
      return;
    }

    _userProvider.updateUser(updatedUser: updateResult.user!);
    _handleSuccess();
  }

  Future<bool> _handleImage(String path) async {
    var pictureResult =
        await storage.uploadFile(File(_profilePicture!.path), path);
    if (pictureResult.status == ResponseStatus.error) {
      return false;
    }

    return true;
  }

  void _handleSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully updated user profile'),
        duration: Duration(
          milliseconds: 500,
        ),
      ),
    );

    Timer(const Duration(milliseconds: 500), () {
      context.pop(_bioController.text);
    });
  }

  void onSelection(List<XFile> image) async {
    if (_updating) return;
    var currScheme = Theme.of(context).colorScheme;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image[0].path,
      uiSettings: [
        AndroidUiSettings(
          initAspectRatio: CropAspectRatioProfile(),
          toolbarTitle: 'Profile Picture',
          toolbarColor: currScheme.surface,
          toolbarWidgetColor: currScheme.onSurface,
          statusBarColor: currScheme.surface,
          backgroundColor: currScheme.surface,
          dimmedLayerColor: currScheme.surface.withOpacity(0.75),
          cropFrameColor: currScheme.onSurface,
          cropGridColor: currScheme.onSurface,
          cropFrameStrokeWidth: 6,
          cropGridStrokeWidth: 6,
          aspectRatioPresets: [
            CropAspectRatioProfile(),
          ],
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Profile Picture',
          minimumAspectRatio: Constants.profile,
          aspectRatioLockEnabled: true,
          aspectRatioPresets: [
            CropAspectRatioProfile(),
          ],
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile == null) return;

    setState(() {
      _profilePicture = XFile(croppedFile.path);
      _removeProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;
    double opacity = _profilePicture != null ? 0.25 : 0.5;

    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    var height = width * (1 / Constants.profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit profile"),
        actions: [
          TextButton(
            onPressed: _updating ? null : _updateUserProfile,
            child: _updating
                ? const LoaderButton(
                    width: Constants.width,
                    height: Constants.height,
                  )
                : const Text("Save"),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, var result) {
          if (didPop) return;

          if (_updating) return;

          context.pop(_currentUserBio);
        },
        child: ListView(
          padding: const EdgeInsets.all(Constants.padding),
          children: [
            SizedBox(
              height: height,
              width: width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _removeProfile
                      ? Container(
                          color: currTheme.onSecondary,
                          child: const Icon(
                            Icons.person,
                            size: Constants.height * 15,
                          ),
                        )
                      : _profilePicture != null
                          ? Image.file(
                              File(_profilePicture!.path),
                              fit: BoxFit.cover,
                              cacheHeight: Constants.editProfileCachedHeight,
                            )
                          : _userProvider.profilePicture.isNotEmpty
                              ? CachedNetworkImage(
                                  cacheKey: _userProvider.profilePicture,
                                  imageUrl: _userProvider.signedProfilePicture,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  height: Constants.height * 15,
                                  memCacheHeight:
                                      Constants.editProfileCachedHeight,
                                )
                              : Container(
                                  color: currTheme.onSecondary,
                                  child: const Icon(
                                    Icons.person,
                                    size: Constants.height * 15,
                                  ),
                                ),
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: Constants.padding,
                      left: Constants.padding,
                      right: Constants.padding,
                    ),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          currTheme.surface.withOpacity(opacity),
                          currTheme.surface.withOpacity(opacity),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ImagePickerWidget(
                          "",
                          onSelection: onSelection,
                          icon: const Icon(Icons.photo_camera),
                        ),
                        IconButton.filled(
                            onPressed: _updating
                                ? null
                                : () {
                                    if (!_removeProfile) {
                                      setState(() {
                                        _removeProfile = true;
                                      });
                                    }
                                  },
                            icon: const Icon(Icons.delete),
                            color: currTheme.onError,
                            style: IconButton.styleFrom(
                              backgroundColor: currTheme.error,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: Constants.gap * 2,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    enabled: !_updating,
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Name",
                      hintText: "Name...",
                    ),
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }
                      _nameController.text = value.trim();
                    },
                    validator: (value) {
                      var nameStatus = ValidateInput.validateName(value);

                      if (!nameStatus.isValid) {
                        return nameStatus.message;
                      }

                      return null;
                    },
                    maxLength: 30,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(
                    height: Constants.gap,
                  ),
                  TextFormField(
                    enabled: !_updating,
                    controller: _bioController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Bio",
                      hintText: "Bio...",
                    ),
                    onSaved: (value) {
                      if (value == null || value.isEmpty) {
                        return;
                      }
                      _bioController.text = value.trim();
                    },
                    validator: (value) {
                      var bioStatus = ValidateInput.validateBio(value);

                      if (!bioStatus.isValid) {
                        return bioStatus.message;
                      }

                      return null;
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
            const SizedBox(
              height: Constants.gap,
            ),
            if (_errorMessage.isNotEmpty) ErrorText(_errorMessage),
          ],
        ),
      ),
    );
  }
}
