import 'package:flutter/material.dart';

import '../../../../core/data/auth.dart';

class CompleteProfilePicturePage extends StatefulWidget {
  final String username;
  final String name;
  final DateTime dob;

  const CompleteProfilePicturePage(
      {super.key,
      required this.username,
      required this.name,
      required this.dob});

  @override
  State<CompleteProfilePicturePage> createState() =>
      _CompleteProfilePicturePageState();
}

class _CompleteProfilePicturePageState
    extends State<CompleteProfilePicturePage> {
  late final String _username;
  late final String _name;
  late final DateTime _dob;

  @override
  void initState() {
    super.initState();

    _username = widget.username;
    _name = widget.name;
    _dob = widget.dob;
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

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
      body: const Text("image picker"),
    );
  }
}
