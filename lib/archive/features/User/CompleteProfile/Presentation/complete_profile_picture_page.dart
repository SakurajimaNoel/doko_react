import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/archive/core/data/auth.dart';
import 'package:doko_react/archive/core/data/storage.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/display.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/core/helpers/media_type.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/core/widgets/error/error_text.dart';
import 'package:doko_react/archive/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/archive/core/widgets/image_picker/image_picker_widget.dart';
import 'package:doko_react/archive/core/widgets/loader/loader_button.dart';
import 'package:doko_react/archive/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/archive/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  final StorageActions storage = StorageActions(storage: Amplify.Storage);
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  late final UserProvider _userProvider;
  late final String _username;
  late final String _name;
  late final DateTime _dob;
  XFile? _profilePicture;
  bool _completing = false;

  // for cleaning up when mutation fails
  String bucketPath = "";

  @override
  void initState() {
    super.initState();

    _userProvider = context.read<UserProvider>();

    _username = widget.username;
    _name = widget.name;
    _dob = DateTime.parse(widget.dob);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  void onSelection(List<XFile> image) async {
    String? extension =
        MediaType.getExtensionFromFileName(image[0].path, withDot: false);

    if (extension == "gif" ||
        (extension == "webp" && await MediaType.isAnimated(image[0].path))) {
      setState(() {
        _profilePicture = XFile(image[0].path);
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
    });
  }

  Future<void> _completeProfile(RunMutation runMutation) async {
    String? imageExtension =
        MediaType.getExtensionFromFileName(_profilePicture!.path);
    if (imageExtension == null) {
      showMessage("Invalid image selected.");
      return;
    }

    setState(() {
      _completing = true;
    });

    var idResult = await auth.getUserId();
    if (idResult.status == AuthStatus.error) {
      setState(() {
        _completing = false;
      });

      showMessage(idResult.message!);
      return;
    }

    var emailResult = await auth.getEmail();
    if (emailResult.status == AuthStatus.error) {
      setState(() {
        _completing = false;
      });
      showMessage(emailResult.message!);
      return;
    }

    if (emailResult.message == "dokii") {
      setState(() {
        _completing = false;
      });

      showMessage("Invalid user.");
      return;
    }

    String email = emailResult.message!;
    String id = idResult.message!;
    String imageString = DisplayText.generateRandomString();
    bucketPath = "$id/profile/$imageString$imageExtension";

    var pictureResult =
        await storage.uploadFile(File(_profilePicture!.path), bucketPath);

    setState(() {
      _completing = false;
    });
    if (pictureResult.status == ResponseStatus.error) {
      showMessage(pictureResult.value);
      return;
    }

    var userDetails = CompleteUserProfileVariables(
      id: id,
      username: _username,
      email: email,
      dob: _dob,
      name: _name,
      profilePicture: bucketPath,
    );
    runMutation(UserQueries.completeUserProfileVariables(userDetails));
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    var height = width * (1 / Constants.profile);
    double opacity = _profilePicture != null ? 0.25 : 0.5;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Photo"),
        actions: [
          TextButton(
            onPressed: () {
              auth.signOutUser();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SettingsHeading("Profile Information"),
                const Text(
                    "Almost there! Select an image to add as your profile picture."),
                const SizedBox(
                  height: Constants.gap,
                ),
                SizedBox(
                  height: height,
                  width: width,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _profilePicture == null
                          ? Container(
                              color: currTheme.onSecondary,
                              child: const Icon(
                                Icons.person,
                                size: Constants.height * 15,
                              ),
                            )
                          : Image.file(
                              File(_profilePicture!.path),
                              fit: BoxFit.cover,
                              cacheHeight: Constants.editProfileCachedHeight,
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
                        child: ImagePickerWidget(
                          "",
                          onSelection: onSelection,
                          icon: const Icon(Icons.photo_camera),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Mutation(
                  options: MutationOptions(
                      document: gql(UserQueries.completeUserProfile()),
                      onCompleted: (data) async {
                        List res = data?["createUsers"]["users"];
                        UserModel user =
                            await UserModel.createModel(map: res[0]);

                        _userProvider.addUser(user: user);
                      },
                      onError: (error) {
                        storage.deleteFile(bucketPath);
                      }),
                  builder: (RunMutation runMutation, QueryResult? result) {
                    bool loading = _completing || (result?.isLoading ?? false);
                    bool hasException = result?.hasException ?? false;
                    String errorText =
                        hasException ? Constants.errorMessage : "";

                    return Column(
                      children: [
                        if (errorText.isNotEmpty) ...[
                          ErrorText(errorText),
                          const SizedBox(
                            height: Constants.gap * 0.5,
                          ),
                        ],
                        FilledButton(
                          onPressed: loading || _profilePicture == null
                              ? null
                              : () => _completeProfile(runMutation),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(
                              Constants.buttonWidth,
                              Constants.buttonHeight,
                            ),
                          ),
                          child: loading
                              ? const LoaderButton()
                              : const Text("Complete"),
                        ),
                      ],
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
