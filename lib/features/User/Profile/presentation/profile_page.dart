import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/loader.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/configs/router/router_constants.dart';
import '../../../../core/data/auth.dart';
import '../../widgets/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UserProvider _userProvider;
  final UserGraphqlService _userGraphqlService = UserGraphqlService();

  bool _loading = true;
  CompleteUserModel? _user;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();

    _fetchCompleteUser();
  }

  Future<void> _fetchCompleteUser({bool force = false}) async {
    setState(() {
      _loading = true;
    });

    var completeUser = await _userGraphqlService.getCompleteUser(
      _userProvider.id,
      force: force,
    );

    if (completeUser.status == ResponseStatus.error) {
      setState(() {
        _loading = false;
      });
      return;
    }

    if (completeUser.user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    var user = completeUser.user!;
    setState(() {
      _loading = false;
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_userProvider.username),
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
              ),
            )
          ],
        ),
        body: const Loader(),
      );
    } else {
      return ProfileWidget(
        user: _user,
        refreshUser: _fetchCompleteUser,
        self: true,
      );
    }
  }
}
