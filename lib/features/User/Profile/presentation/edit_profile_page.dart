import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/input.dart';
import 'package:doko_react/core/widgets/error_text.dart';
import 'package:doko_react/core/widgets/image_picker_widget.dart';
import 'package:doko_react/core/widgets/loader_button.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/configs/router/router_constants.dart';
import '../../../../core/data/storage.dart';
import '../../../../core/helpers/enum.dart';
import '../../../../core/helpers/mime_type.dart';

class EditProfilePage extends StatefulWidget {
  final Function(String, String, String, bool) callback;
  final EditUserModel user;

  const EditProfilePage(
      {super.key, required this.callback, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final Function(String, String, String, bool) _callback;
  late final EditUserModel _user;

  final UserGraphqlService _userGraphqlService = UserGraphqlService();

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
    _callback = widget.callback;
    _user = widget.user;

    _nameController = TextEditingController(
      text: _user.name,
    );
    _bioController = TextEditingController(
      text: _user.bio,
    );
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

    String id = _user.id;
    String name = _nameController.text;
    String bio = _bioController.text;
    String bucketPath = _user.profilePicture;

    if (!_removeProfile && _profilePicture != null) {
      String? imageExtension =
          MimeType.getExtensionFromFileName(_profilePicture!.path);

      if (imageExtension == null) {
        setState(() {
          _errorMessage = "Invalid image file selected.";
          _updating = false;
        });
        return;
      }

      bucketPath = "$id/profile$imageExtension";

      var imageResult = await _handleImage(bucketPath);
      if (!imageResult) {
        setState(() {
          _errorMessage = "Error uploading profile image.";
          _updating = false;
        });
        return;
      }

      if (_user.profilePicture != bucketPath) {
        StorageActions.deleteFile(_user.profilePicture);
      }
    }

    if (_removeProfile) {
      StorageActions.deleteFile(_user.profilePicture);
      bucketPath = "";
    }

    // updating graph
    var updateResult =
        await _userGraphqlService.updateUserProfile(id, name, bio, bucketPath);

    if (updateResult.status == ResponseStatus.error) {
      String message =
          "Updated user profile image. Error updating other fields.";
      if (_profilePicture == null) {
        message = "Error updating user profile fields.";
      } else {
        _callback(bucketPath, _user.bio, _user.name, true);
      }

      setState(() {
        _errorMessage = message;
        _updating = false;
      });
      return;
    }

    bool updateProfile = _removeProfile ? true : _profilePicture != null;
    _callback(bucketPath, bio, name, updateProfile);
    _handleSuccess();
  }

  Future<bool> _handleImage(String path) async {
    var pictureResult =
        await StorageActions.uploadFile(File(_profilePicture!.path), path);
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

    // Delay the navigation
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        context.goNamed(
          RouterConstants.profile,
        );
      },
    );
  }

  void onSelection(List<XFile> image) {
    if (_updating) return;

    setState(() {
      _profilePicture = image[0];
      _removeProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;
    double opacity = _profilePicture != null ? 0.25 : 0.5;

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
        onPopInvoked: (bool didPop) {
          if (didPop) return;

          if (_updating) return;

          context.pop();
        },
        child: ListView(
          padding: const EdgeInsets.all(Constants.padding),
          children: [
            SizedBox(
              height: Constants.height * 15,
              width: double.maxFinite,
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
                            )
                          : _user.imgURL.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _user.imgURL,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  height: Constants.height * 15,
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
                    ),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          currTheme.surface.withOpacity(opacity),
                          currTheme.surface.withOpacity(opacity),
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
                  )
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
