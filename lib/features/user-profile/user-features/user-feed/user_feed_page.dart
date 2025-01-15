import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({super.key});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doki"),
        actions: [
          TextButton(
            onPressed: () {
              createOptions();
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
    );
  }

  void createOptions() {
    final width = MediaQuery.sizeOf(context).width;
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          height: Constants.height * 15,
          width: width,
          padding: EdgeInsets.all(Constants.padding),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: Constants.gap,
              runSpacing: Constants.gap,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: const Text("Story"),
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createPost);
                  },
                  label: const Text("Post"),
                  icon: const Icon(Icons.add_box_outlined),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: const Text("Page"),
                  icon: const Icon(Icons.post_add),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
