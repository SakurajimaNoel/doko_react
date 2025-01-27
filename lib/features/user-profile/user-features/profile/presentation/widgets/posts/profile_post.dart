import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_widget.dart';
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

  bool loading = false;

  @override
  void initState() {
    super.initState();

    username = widget.username;
    graphKey = generateUserNodeKey(username);
    user = graph.getValueByKey(graphKey)! as CompleteUserEntity;
  }

  Widget buildPostItems(BuildContext context, int index) {
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
      if (!loading) {
        loading = true;
        context.read<ProfileBloc>().add(LoadMoreProfilePostEvent(
              postDetails: UserProfileNodesInput(
                username: username,
                cursor: userPost.pageInfo.endCursor!,
                currentUsername:
                    (context.read<UserBloc>().state as UserCompleteState)
                        .username,
              ),
            ));
      }

      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    // show user post
    return PostWidget(
      postKey: userPost.items[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previousState, state) {
        return state is ProfilePostLoadResponse;
      },
      listener: (context, state) {
        loading = false;

        if (state is ProfilePostLoadError) {
          showError(context, state.message);
          return;
        }

        // handle post load success
        final Nodes userPost = user.posts;

        context.read<UserActionBloc>().add(UserActionPostLoadEvent(
              postCount: userPost.items.length,
              username: username,
            ));
      },
      child: BlocBuilder<UserActionBloc, UserActionState>(
        buildWhen: (previousState, state) {
          return (state is UserActionLoadPosts && state.username == username) ||
              (state is UserActionNewPostState && username == currentUsername);
        },
        builder: (context, state) {
          final Nodes userPost = user.posts;

          if (userPost.items.isEmpty) {
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

          return SliverList.separated(
            itemCount: userPost.items.length + 1,
            itemBuilder: buildPostItems,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: Constants.gap * 2.5,
              );
            },
          );
        },
      ),
    );
  }
}
