import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/discussions/discussion_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/polls/poll_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Timeline extends StatefulWidget {
  const Timeline({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
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

  Widget buildTimelineItems(BuildContext context, int index) {
    final Nodes userTimeline = user.timeline;

    if (index >= userTimeline.items.length) {
      /// fetch more posts if exits
      if (!userTimeline.pageInfo.hasNextPage) {
        return const SizedBox.shrink();
      }

      // fetch more post
      if (!loading) {
        loading = true;
        context.read<ProfileBloc>().add(LoadUserTimelineNodesEvent(
              timelineDetails: UserProfileNodesInput(
                username: username,
                cursor: userTimeline.pageInfo.endCursor!,
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

    String nodeKey = userTimeline.items[index];
    DokiNodeType? nodeType = getNodeTypeFromKey(nodeKey);
    if (nodeType == null) {
      return const SizedBox.shrink();
    }

    if (nodeType == DokiNodeType.post) {
      return PostWidget(
        postKey: nodeKey,
      );
    }

    if (nodeType == DokiNodeType.discussion) {
      return DiscussionWidget(
        discussionKey: nodeKey,
      );
    }
    return PollWidget(
      pollKey: nodeKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previousState, state) {
        return state is ProfileTimelineLoadResponse;
      },
      listener: (context, state) {
        loading = false;

        if (state is ProfileTimelineLoadError) {
          showError(state.message);
          return;
        }

        // handle post load success
        final Nodes userTimeline = user.timeline;

        context.read<UserActionBloc>().add(UserActionTimelineLoadEvent(
              itemCount: userTimeline.items.length,
              username: username,
            ));
      },
      child: BlocBuilder<UserActionBloc, UserActionState>(
        buildWhen: (previousState, state) {
          return (state is UserActionLoadTimelineState &&
                  state.username == username) ||
              (state is UserActionNewRootNodeState &&
                  (state.username == username ||
                      state.usersTagged.contains(username)));
        },
        builder: (context, state) {
          final Nodes userTimeline = user.timeline;

          if (userTimeline.items.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  "${user.name} has not uploaded anything.",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return SliverList.separated(
            itemCount: userTimeline.items.length + 1,
            itemBuilder: buildTimelineItems,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: Constants.gap * 1.75,
              );
            },
          );
        },
      ),
    );
  }
}
