import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({super.key});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doki"),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: Constants.gap,
        ),
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
          IconButton(
            onPressed: () {
              context.pushNamed(RouterConstants.messageInbox);
            },
            color: currTheme.primary,
            icon: const Badge(
              label: Text("99+"),
              child: Icon(
                Icons.chat,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: SingleChildScrollView(
          child: Column(
            spacing: Constants.gap * 2,
            children: [
              UserWidget.preview(
                userKey: generateUserNodeKey(username),
              ),
            ],
          ),
        ),
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
          padding: const EdgeInsets.all(Constants.padding),
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: Constants.gap,
              runSpacing: Constants.gap,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createPost);
                  },
                  label: const Text("Post"),
                  icon: const Icon(Icons.calendar_view_day_rounded),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createDiscussion);
                  },
                  label: const Text("Discussion"),
                  icon: const Icon(Icons.text_snippet),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.pop();
                    context.pushNamed(RouterConstants.createPoll);
                  },
                  label: const Text("Poll"),
                  icon: const Icon(Icons.poll),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  label: const Text("Page"),
                  icon: const Icon(Icons.pages),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
