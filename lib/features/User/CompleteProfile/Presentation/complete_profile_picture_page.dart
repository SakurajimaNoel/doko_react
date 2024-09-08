import 'dart:io';
import 'dart:math';

import 'package:doko_react/core/data/storage.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/helpers/mime_type.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error_widget.dart';
import 'package:doko_react/core/widgets/image_picker_widget.dart';
import 'package:doko_react/core/widgets/loader_button.dart';
import 'package:doko_react/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/auth.dart';
import '../../../../core/widgets/settings_heading.dart';

class CompleteProfilePicturePage extends StatefulWidget {
  final String username;
  final String name;
  final String dob;

  const CompleteProfilePicturePage({
    super.key,
    required this.username,
    required this.name,
    required this.dob,
  });

  @override
  State<CompleteProfilePicturePage> createState() =>
      _CompleteProfilePicturePageState();
}

class _CompleteProfilePicturePageState
    extends State<CompleteProfilePicturePage> {
  final UserGraphqlService _graphqlService = UserGraphqlService();
  late final UserProvider _userProvider;
  late final String _username;
  late final String _name;
  late final DateTime _dob;
  XFile? _profilePicture;
  bool _completing = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();

    _username = widget.username;
    _name = widget.name;
    _dob = DateTime.parse(widget.dob);
  }

  void onSelection(List<XFile> image) {
    setState(() {
      _profilePicture = image[0];
    });
  }

  Future<void> _completeProfile() async {
    String? imageExtension =
        MimeType.getExtensionFromFileName(_profilePicture!.path);
    if (imageExtension == null) {
      setState(() {
        _errorMessage = "Invalid image selected.";
      });
      return;
    }

    setState(() {
      _completing = true;
      _errorMessage = "";
    });

    var idResult = await AuthenticationActions.getUserId();
    if (idResult.status == AuthStatus.error) {
      setState(() {
        _completing = false;
        _errorMessage = idResult.message!;
      });
      return;
    }

    var emailResult = await AuthenticationActions.getEmail();
    if (emailResult.status == AuthStatus.error) {
      setState(() {
        _completing = false;
        _errorMessage = emailResult.message!;
      });
      return;
    }

    if (emailResult.message == "dokii") {
      setState(() {
        _completing = false;
        _errorMessage = "Invalid user.";
      });
      return;
    }

    String email = emailResult.message!;
    String id = idResult.message!;
    String bucketPath = "$id/profile$imageExtension";

    var pictureResult = await StorageActions.uploadFile(
        File(_profilePicture!.path), bucketPath);
    if (pictureResult.status == ResponseStatus.error) {
      setState(() {
        _completing = false;
        _errorMessage = pictureResult.value;
      });
      return;
    }

    var variables = CompleteUserProfileVariables(
      id: id,
      username: _username,
      email: email,
      dob: _dob,
      name: _name,
      profilePicture: bucketPath,
    );
    var profileResponse = await _graphqlService.completeUserProfile(variables);

    if (profileResponse.status == ResponseStatus.error) {
      setState(() {
        _completing = false;
        _errorMessage = "Oops! Somethings went wrong.";
      });

      StorageActions.deleteFile(bucketPath);
      return;
    }

    _userProvider.addUser(
      user: UserModel(
        name: _name,
        username: _username,
        profilePicture: bucketPath,
        id: id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;
    final double radius = min(
      MediaQuery.sizeOf(context).width / 2 - Constants.padding,
      Constants.radius * 10,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete profile"),
        actions: [
          TextButton(
            onPressed: () {
              AuthenticationActions.signOutUser();
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                color: currTheme.error,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeading("Profile Information"),
            const Text(
                "Almost there! Select an image to add as your profile picture."),
            const SizedBox(
              height: Constants.gap * 0.5,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      _profilePicture == null
                          ? CircleAvatar(
                              radius: radius,
                              backgroundColor: currTheme.secondaryContainer,
                              child: Icon(
                                Icons.account_circle_outlined,
                                color: currTheme.onSecondaryContainer,
                                size: radius * 2,
                              ),
                            )
                          : CircleAvatar(
                              radius: radius,
                              backgroundImage: FileImage(
                                File(_profilePicture!.path),
                              ),
                            ),
                      const SizedBox(
                        height: Constants.gap * 0.5,
                      ),
                      ImagePickerWidget(
                        _profilePicture == null ? "Select" : "Change",
                        onSelection: onSelection,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      if (_errorMessage.isNotEmpty) ...[
                        ErrorText(_errorMessage),
                        const SizedBox(
                          height: Constants.gap * 0.5,
                        ),
                      ],
                      FilledButton(
                        onPressed: _completing || _profilePicture == null
                            ? null
                            : _completeProfile,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(
                            Constants.buttonWidth,
                            Constants.buttonHeight,
                          ),
                        ),
                        child: _completing
                            ? const LoaderButton()
                            : const Text("Complete"),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
