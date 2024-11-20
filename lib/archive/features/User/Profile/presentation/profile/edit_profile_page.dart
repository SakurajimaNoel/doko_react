import 'dart:async';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/archive/core/data/storage.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/display.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/core/helpers/input.dart';
import 'package:doko_react/archive/core/helpers/media_type.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/core/widgets/image_picker/image_picker_widget.dart';
import 'package:doko_react/archive/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/archive/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final CompleteUserModel user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final StorageActions storage = StorageActions(storage: Amplify.Storage);

  late final UserProvider _userProvider;
  late final CompleteUserModel user;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();

  bool _updating = false;
  bool _removeProfile = false;
  XFile? _profilePicture;

  @override
  void initState() {
    super.initState();

    user = widget.user;
    _userProvider = context.read<UserProvider>();

    _nameController = TextEditingController(
      text: user.name,
    );
    _bioController = TextEditingController(
      text: user.bio,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  bool needsUpdate() {
    if (user.name.trim() != _nameController.text.trim()) return true;
    if (user.bio.trim() != _bioController.text.trim()) return true;

    // check if profile is same or not
    if (_profilePicture != null) return true;
    if (user.profilePicture.isNotEmpty && _removeProfile) return true;

    return false;
  }

  Future<void> _updateUserProfile(RunMutation runMutation) async {
    bool validate = _formKey.currentState?.validate() ?? false;
    if (!validate) {
      return;
    }
    _formKey.currentState?.save();

    if (!needsUpdate()) {
      context.pop();
      return;
    }

    setState(() {
      _updating = true;
    });

    String username = _userProvider.username;
    String userId = _userProvider.id;
    String name = _nameController.text;
    String bio = _bioController.text;
    String bucketPath = user.profilePicture;

    // when new profile picture is selected
    if (_profilePicture != null) {
      String? imageExtension =
          MediaType.getExtensionFromFileName(_profilePicture!.path);

      if (imageExtension == null) {
        showMessage("Invalid image file selected.");
        setState(() {
          _updating = false;
        });
        return;
      }

      String imageString = DisplayText.generateRandomString();
      bucketPath = "$userId/profile/$imageString$imageExtension";

      var imageResult = await _handleImage(bucketPath);
      if (!imageResult) {
        showMessage("Error updating profile image.");
        setState(() {
          _updating = false;
        });
        return;
      }
    }

    // when profile picture is removed
    if (_removeProfile) {
      bucketPath = "";
    }

    runMutation(UserQueries.updateUserProfileVariables(
      username: username,
      name: name,
      bio: bio,
      profilePicture: bucketPath,
    ));
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
    showMessage('Successfully updated user profile');
    context.pop();
  }

  void onSelection(List<XFile> image) async {
    if (_updating) return;
    String? extension =
        MediaType.getExtensionFromFileName(image[0].path, withDot: false);

    if (extension == "gif" ||
        (extension == "webp" && await MediaType.isAnimated(image[0].path))) {
      setState(() {
        _profilePicture = XFile(image[0].path);
        _removeProfile = false;
      });
      return;
    }

    if (!mounted) return;
    var currScheme = Theme.of(context).colorScheme;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image[0].path,
      aspectRatio: const CropAspectRatio(
        ratioX: Constants.profileWidth,
        ratioY: Constants.profileHeight,
      ),
      uiSettings: [
        AndroidUiSettings(
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
        ),
        IOSUiSettings(
          title: 'Profile Picture',
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

    bool noProfilePictureUi = _removeProfile ||
        (user.profilePicture.isEmpty && _profilePicture == null);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit profile"),
        actions: [
          Mutation(
            options: MutationOptions(
              document: gql(UserQueries.updateUserProfile()),
              onError: (error) {
                // handle error updating graph
                _updating = false;
              },
              onCompleted: (data) async {
                if (_removeProfile || _profilePicture != null) {
                  storage.deleteFile(user.profilePicture);
                }
                _updating = false;
                _handleSuccess();
              },
              update: (cache, result) {
                if (result == null || result.hasException) return;

                final updatedUserDetails =
                    result.data?["updateUsers"]["users"][0];
                final profilePicture = updatedUserDetails["profilePicture"];
                final name = updatedUserDetails["name"];
                final bio = updatedUserDetails["bio"];

                final QueryOptions options = QueryOptions(
                  document: gql(UserQueries.getCompleteUser()),
                  variables: UserQueries.getCompleteUserVariables(
                    user.username,
                    currentUsername: user.username,
                  ),
                );

                var cacheKey = Request(
                  operation: Operation(
                    document: gql(UserQueries.getCompleteUser()),
                  ),
                  variables: UserQueries.getCompleteUserVariables(
                    user.username,
                    currentUsername: user.username,
                  ),
                );

                cacheKey = Operation(
                  document: gql(UserQueries.getCompleteUser()),
                ).asRequest(
                  variables: UserQueries.getCompleteUserVariables(
                    user.username,
                    currentUsername: user.username,
                  ),
                );

                safePrint(cacheKey == options.asRequest);

                var val = cache.readQuery(options.asRequest);
                var normalizedRead = (cache as GraphQLCache)
                    .readNormalized("User:${_userProvider.id}");
                String normalizedCacheKey = "User:${_userProvider.id}";

                // if (val != null) {
                //   val["users"][0]["name"] = name;
                //   val["users"][0]["profilePicture"] = profilePicture;
                //   val["users"][0]["bio"] = bio;
                //
                //   cache.writeQuery(cacheKey, data: val);
                // }
                var cacheVal = _userProvider.trial;
                if (cacheVal != null) {
                  cacheVal["users"][0]["name"] = name;
                  cacheVal["users"][0]["profilePicture"] = profilePicture;
                  cacheVal["users"][0]["bio"] = bio;

                  cache.writeQuery(cacheKey, data: cacheVal);
                }
                if (normalizedRead != null) {
                  normalizedRead["name"] = name;
                  normalizedRead["profilePicture"] = profilePicture;
                  normalizedRead["bio"] = bio;

                  (cache).writeNormalized(normalizedCacheKey, normalizedRead);
                  cache.shouldBroadcast();
                }
                safePrint("cache value");
                safePrint(val);
                safePrint(normalizedRead);

                if (val == null) {
                  final cacheDump = cache.store.toMap();
                  safePrint("cache dump");
                  cacheDump.forEach((key, value) {
                    safePrint("key");
                    safePrint(key);
                    safePrint("value");
                    if (value.toString().length < 1024) {
                      safePrint(value);
                    } else {
                      var strVal = value.toString();
                      var len = strVal.length;
                      var parts = len / 1024;
                      int start = 0;
                      for (int i = 0; i < parts; i++) {
                        int end = start + 1023;
                        end = end > len ? len : end;
                        safePrint(strVal.substring(start, end));
                        start = end;
                      }
                      if (start != len) {
                        safePrint(strVal.substring(start));
                      }
                    }
                  });
                }
              },
            ),
            builder: (RunMutation runMutation, QueryResult? result) {
              bool loading = _updating || (result?.isLoading ?? false);

              if (loading) {
                return const Padding(
                  padding: EdgeInsets.only(
                    right: Constants.padding,
                  ),
                  child: SizedBox(
                    width: Constants.width,
                    height: Constants.height,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              return TextButton(
                onPressed: () => _updateUserProfile(runMutation),
                child: const Text("Save"),
              );
            },
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, var result) {
          if (didPop) return;

          if (_updating) return;

          context.pop();
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
                  noProfilePictureUi
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
                          : CachedNetworkImage(
                              cacheKey: user.profilePicture,
                              imageUrl: user.signedProfilePicture,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              height: Constants.height * 15,
                              memCacheHeight: Constants.editProfileCachedHeight,
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
                        if (!noProfilePictureUi)
                          IconButton.filled(
                            onPressed: _updating
                                ? null
                                : () {
                                    if (!_removeProfile) {
                                      setState(() {
                                        _removeProfile = true;
                                        _profilePicture = null;
                                      });
                                    }
                                  },
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
          ],
        ),
      ),
    );
  }
}
