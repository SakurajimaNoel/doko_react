import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:doko_react/features/authentication/presentation/screens/mfa_setup_page.dart';
import 'package:flutter/material.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({super.key});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  static const double _padding = 16;

  @override
  Widget build(BuildContext context) {
    ColorScheme currScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dokii"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MfaSetupPage()));
            },
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          ),
          TextButton(
              onPressed: () {
                AuthenticationActions.signOutUser();
              },
              child: Text(
                "Sign out",
                style: TextStyle(color: currScheme.error),
              ))
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: _padding, right: _padding, bottom: _padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("user feed!"),
            ],
          ),
        ),
      ),
    );
  }
}
