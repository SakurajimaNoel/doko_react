import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({
    super.key,
  });

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dokii"),
        actions: [
          TextButton(
            onPressed: () {
              context.pushNamed(RouterConstants.createPost);
            },
            child: const Text("Create"),
          ),
          IconButton(
            onPressed: () {
              context.pushNamed(RouterConstants.userSearch);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              context.pushNamed(RouterConstants.pendingRequests);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(Constants.padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("user feed!"),
          ],
        ),
      ),
    );
  }
}
