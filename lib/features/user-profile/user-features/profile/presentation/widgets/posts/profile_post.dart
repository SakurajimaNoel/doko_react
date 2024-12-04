import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/posts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePost extends StatefulWidget {
  const ProfilePost({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<ProfilePost> createState() => _ProfilePostState();
}

class _ProfilePostState extends State<ProfilePost> {
  final UserGraph graph = UserGraph();

  late final String username;
  late final String graphKey;
  late CompleteUserEntity user;

  @override
  void initState() {
    super.initState();

    username = widget.username;
    graphKey = generateUserNodeKey(username);
    user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
  }

  Widget buildPostItem(BuildContext context, int index) {
    final Nodes userPost = user.posts;

    if (index >= userPost.items.length) {
      /// fetch more posts if exits
      if (!userPost.pageInfo.hasNextPage) {
        return Center(
          child: Text(
            "${user.name} has no more posts.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      // fetch more post

      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    // show user post
    return Posts(postKey: userPost.items[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (user.posts.items.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "${user.name} has not uploaded any posts.",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionLoadPosts && state.username == username;
      },
      builder: (context, state) {
        user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
        final Nodes userPost = user.posts;

        return SliverList.separated(
          itemCount: userPost.items.length + 1,
          itemBuilder: buildPostItem,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: Constants.gap * 2.5,
            );
          },
        );
      },
    );
  }
}
