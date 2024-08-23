import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/data/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double _padding = 16;

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              context.goNamed(RouterConstants.settings);
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
          padding: EdgeInsets.only(
              left: _padding, right: _padding, bottom: _padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("profile page!"),
            ],
          ),
        ),
      ),
    );
  }
}
