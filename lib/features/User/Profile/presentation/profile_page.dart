import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/auth.dart';
import '../../../../core/helpers/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UserProvider _userProvider;
  late final String _username;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _username = _userProvider.username;
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_username),
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
                style: TextStyle(
                  color: currScheme.error,
                ),
              ))
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Constants.padding),
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
