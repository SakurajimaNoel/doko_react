import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:flutter/material.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({super.key});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("user feed!"),
            ElevatedButton(
                onPressed: () {
                  AuthenticationActions.signOutUser();
                },
                child: const Text("Sign out"))
          ],
        ),
      ),
    );
  }
}
