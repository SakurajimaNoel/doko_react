import 'dart:io';
import 'dart:math';

import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/data/auth.dart';
import '../../../application/settings/widgets/settings_heading.dart';

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
  late final String _username;
  late final String _name;
  late final DateTime _dob;
  XFile? _profilePicture;
  bool _completing = false;

  @override
  void initState() {
    super.initState();

    _username = widget.username;
    _name = widget.name;
    _dob = DateTime.parse(widget.dob);
  }

  void onSelection(List<XFile> image) {
    setState(() {
      _profilePicture = image[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;
    const double padding = 16;
    final double radius =
        min(MediaQuery.sizeOf(context).width / 2 - padding, 175.00);

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
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeading("Profile Information"),
            const Text(
                "Almost there! Select an image to add as your profile picture."),
            const SizedBox(
              height: 8,
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
                        height: 8,
                      ),
                      ImagePickerWidget(
                        _profilePicture == null ? "Select" : "Change",
                        onSelection: onSelection,
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: _completing ? null : () {},
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: _completing
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Complete"),
                    ),
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
