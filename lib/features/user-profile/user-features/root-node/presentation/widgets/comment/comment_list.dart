import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/widgets/comment/comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentList extends StatefulWidget {
  const CommentList({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final UserGraph graph = UserGraph();

  late final postId = widget.postId;
  late final postKey = generatePostNodeKey(widget.postId);
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  late final PostEntity post;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    post = graph.getValueByKey(postKey)! as PostEntity;
  }

  Widget buildCommentItems(BuildContext context, int index) {
    final Nodes comments = post.comments;

    if (index >= comments.items.length) {
      if (!comments.pageInfo.hasNextPage) {
        return const Center(
          child: Text(
            "No more comments.",
          ),
        );
      }

      if (!loading) {
        loading = true;
        context.read<RootNodeBloc>().add(LoadMoreCommentEvent(
              details: GetCommentsInput(
                nodeId: postId,
                username: username,
                isPost: true,
                cursor: comments.pageInfo.endCursor!,
              ),
            ));
      }
      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    return CommentWidget(
      commentKey: comments.items[index],
      parentNodeId: postId,
      key: ValueKey(comments.items[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionNewCommentState && state.nodeId == postId;
      },
      builder: (context, state) {
        bool isEmpty = post.comments.items.isEmpty;

        if (isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: Constants.height * 5,
              child: Center(
                child: Text("No comments here."),
              ),
            ),
          );
        }

        return BlocConsumer<RootNodeBloc, RootNodeState>(
          listenWhen: (previousState, state) {
            return state is CommentLoadSuccess ||
                (state is LoadErrorState && state.nodeId == postId);
          },
          listener: (context, state) {
            if (loading) loading = false;
          },
          buildWhen: (previousState, state) {
            return state is CommentLoadSuccess;
          },
          builder: (context, state) {
            return SliverList.separated(
              itemCount: post.comments.items.length + 1,
              itemBuilder: buildCommentItems,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: Constants.gap * 1.5,
                );
              },
            );
          },
        );
      },
    );
  }
}
