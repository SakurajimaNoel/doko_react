
import 'package:flutter/material.dart';

import '../../../../core/data/auth.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("complete profile"),
      ),
      body: ElevatedButton(
          onPressed: () {
            AuthenticationActions.signOutUser();
          },
          child: const Text("signout")),
    );
  }
}
