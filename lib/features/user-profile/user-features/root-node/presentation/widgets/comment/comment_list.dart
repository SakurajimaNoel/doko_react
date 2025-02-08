import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/widgets/comment/comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentList extends StatefulWidget {
  const CommentList({
    super.key,
    required this.parentNodeId,
    required this.parentNodeType,
  });

  final String parentNodeId;
  final DokiNodeType parentNodeType;

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final UserGraph graph = UserGraph();

  late final parentNodeId = widget.parentNodeId;
  late final parentNodeType = widget.parentNodeType;
  late final String parentGraphKey;
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  bool loading = false;

  late final NodeWithCommentEntity parentNode;

  @override
  void initState() {
    super.initState();

    parentGraphKey = parentNodeType.keyGenerator(parentNodeId);
    parentNode = graph.getValueByKey(parentGraphKey)! as NodeWithCommentEntity;
  }

  Widget buildCommentItems(BuildContext context, int index) {
    final Nodes comments = parentNode.nodeComments;

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
        context.read<RootNodeBloc>().add(LoadMoreSecondaryNodesEvent(
              details: GetCommentsInput(
                nodeId: parentNodeId,
                username: username,
                nodeType: parentNodeType,
                cursor: comments.pageInfo.endCursor!,
              ),
            ));
      }
      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    if (parentNodeType == DokiNodeType.comment) {
      return CommentWidget.reply(
        commentKey: comments.items[index],
        parentNodeId: parentNodeId,
        key: ValueKey(getCommentIdFromCommentKey(comments.items[index])),
      );
    }

    return CommentWidget(
      commentKey: comments.items[index],
      parentNodeId: parentNodeId,
      key: ValueKey(getCommentIdFromCommentKey(comments.items[index])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionNewCommentState &&
            state.nodeId == parentNodeId;
      },
      builder: (context, state) {
        bool isEmpty = parentNode.nodeComments.items.isEmpty;

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
            return state is SecondaryLoadSuccess ||
                (state is LoadErrorState && state.nodeId == parentNodeId);
          },
          listener: (context, state) {
            if (loading) loading = false;
          },
          buildWhen: (previousState, state) {
            return state is SecondaryLoadSuccess;
          },
          builder: (context, state) {
            return SliverList.separated(
              itemCount: parentNode.nodeComments.items.length + 1,
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
