import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/loader.dart';
import 'package:doko_react/features/User/data/services/post_graphql_service.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:doko_react/features/User/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/auth.dart';

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
  final UserGraphqlService _userGraphqlService = UserGraphqlService();
  final PostGraphqlService _postGraphqlService = PostGraphqlService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _username = _userProvider.username;

    // _trial();
  }

  // TODO: remove this after completing
  Future<void> _trial() async {
    var completeUser =
        await _userGraphqlService.getCompleteUser(_userProvider.id);

    if (completeUser.status == ResponseStatus.error) {
      safePrint("error");
      return;
    }

    if (completeUser.user == null) {
      safePrint("user null");
      return;
    }

    var user = completeUser.user!;

    var tempPosts = user.posts;
    int len = tempPosts.length;

    if (len <= 0) {
      safePrint("no posts");
      return;
    }

    DateTime cursor = tempPosts[len - 1].createdOn;
    var posts =
        await _postGraphqlService.getPostsByUserId(_userProvider.id, cursor);

    if (posts.status == ResponseStatus.error) {
      safePrint("posts error");
      return;
    }

    var postsValues = posts.posts;
    len = postsValues.length;
    safePrint(postsValues[len - 1].caption);
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: _loading ? const Loader() : const Profile(),
    );
  }
}
