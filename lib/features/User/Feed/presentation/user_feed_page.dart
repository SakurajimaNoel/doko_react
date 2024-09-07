import 'package:flutter/material.dart';

import '../../../../core/helpers/constants.dart';

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
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Constants.padding),
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
