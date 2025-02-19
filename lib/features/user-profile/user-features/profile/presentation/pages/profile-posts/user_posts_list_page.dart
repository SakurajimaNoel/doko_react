import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPostsListPage extends StatefulWidget {
  const UserPostsListPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<UserPostsListPage> createState() => _UserPostsListPageState();
}

class _UserPostsListPageState extends State<UserPostsListPage> {
  late final String username;
  late final String currentUsername;
  late final bool self;

  late final String graphKey;
  final graph = UserGraph();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    username = widget.username;
    currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;

    self = username == currentUsername;
    graphKey = generateUserNodeKey(username);
  }

  @override
  Widget build(BuildContext context) {
    final UserProfileNodesInput details = UserProfileNodesInput(
      username: username,
      currentUsername: currentUsername,
    );

    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("$username posts"),
      ),
    );
  }
}
