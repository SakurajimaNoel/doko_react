import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/widgets/comment/comment_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/widgets/comment/comment_list.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/widgets/comment/comment_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({
    super.key,
    required this.commentId,
    required this.rootNodeId,
    required this.rootNodeType,
  });

  final String commentId;

  /// root node and root node type help to identify where to redirect
  /// discussion or post
  final String rootNodeId;
  final DokiNodeType rootNodeType;

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final UserGraph graph = UserGraph();
  late final commentKey = generateCommentNodeKey(widget.commentId);

  late final DokiNodeType rootNodeType = widget.rootNodeType;
  late final String rootNodeId = widget.rootNodeId;
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  Future<void> handleCommentRefreshEvent() async {
    // todo: handle this
    context.read<UserActionBloc>().add(UserActionPrimaryNodeRefreshEvent(
          nodeId: widget.commentId,
        ));
  }

  void showToastError(String message) {
    showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    bool invalidNode = rootNodeType == DokiNodeType.user;

    if (invalidNode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Comment"),
        ),
        body: const Center(
          child: StyledText.error("Invalid node type."),
        ),
      );
    }

    final scrollCacheHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comment"),
        actions: [
          TextButton(
            onPressed: () {
              // redirect to correct page
              if (rootNodeType == DokiNodeType.post) {
                // go to post page
                context.pushReplacementNamed(
                  RouterConstants.userPost,
                  pathParameters: {
                    "postId": rootNodeId,
                  },
                );
              }
            },
            child: Text("Go to ${widget.rootNodeType.name} "),
          ),
          const SizedBox(
            width: Constants.gap,
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<RootNodeBloc>()
          ..add(CommentLoadEvent(
            details: GetNodeInput(
              nodeId: widget.commentId,
              username: username,
            ),
          )),
        child: BlocConsumer<RootNodeBloc, RootNodeState>(
          listenWhen: (previousState, state) {
            return state is LoadErrorState;
          },
          listener: (context, state) {
            if (state is LoadErrorState) showError(context, state.message);
          },
          buildWhen: (previousState, state) {
            return state is RootNodeInitial;
          },
          builder: (context, state) {
            bool loading = state is RootNodeLoading;
            bool repliesLoading = state is SecondaryLoadingState;

            bool commentError = state is RootNodeErrorState;
            bool repliesError = state is SecondaryNodeErrorState;

            if (loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (commentError) {
              return Center(
                child: StyledText.error(state.message),
              );
            }
            final CommentEntity comment =
                graph.getValueByKey(commentKey)! as CommentEntity;

            return ChangeNotifierProvider(
              create: (BuildContext context) {
                return NodeCommentProvider(
                  focusNode: FocusNode(),
                  rootNodeId: comment.id,
                  rootNodeCreatedBy: getUsernameFromUserKey(comment.commentBy),
                  targetByUser: getUsernameFromUserKey(comment.commentBy),
                  rootNodeType: DokiNodeType.post,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        Future postBloc =
                            context.read<RootNodeBloc>().stream.first;

                        context.read<RootNodeBloc>().add(CommentRefreshEvent(
                              details: GetNodeInput(
                                nodeId: widget.commentId,
                                username: username,
                              ),
                            ));

                        final RootNodeState state = await postBloc;

                        if (state is PrimaryNodeRefreshErrorState) {
                          if (!mounted) return;
                          showToastError(state.message);
                          return;
                        }

                        if (!mounted) return;

                        handleCommentRefreshEvent();
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        cacheExtent: scrollCacheHeight,
                        slivers: [
                          SliverToBoxAdapter(
                            child: CommentWidget(
                              commentKey: commentKey,
                              parentNodeId: comment.id,
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(
                              height: Constants.gap * 2,
                            ),
                          ),
                          if (repliesError) ...[
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: Constants.height * 5,
                                child: StyledText.error(state.message),
                              ),
                            ),
                          ] else
                            repliesLoading
                                ? const SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: Constants.height * 5,
                                      child: Center(
                                        child: SmallLoadingIndicator(),
                                      ),
                                    ),
                                  )
                                : BlocBuilder<UserActionBloc, UserActionState>(
                                    buildWhen: (previousState, state) {
                                      return state
                                              is UserActionPrimaryNodeRefreshState &&
                                          state.nodeId == comment.id;
                                    },
                                    builder: (context, state) {
                                      DateTime now;
                                      if (state
                                          is UserActionPrimaryNodeRefreshState) {
                                        now = state.now;
                                      } else {
                                        now = DateTime.now();
                                      }

                                      return CommentList(
                                        parentNodeId: widget.commentId,
                                        parentNodeType: DokiNodeType.comment,
                                        key: ObjectKey({
                                          "postId": comment.id,
                                          "lastFetch": now,
                                        }),
                                      );
                                    },
                                  ),
                          const SliverToBoxAdapter(
                            child: SizedBox(
                              height: Constants.gap * 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const CommentInput(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
