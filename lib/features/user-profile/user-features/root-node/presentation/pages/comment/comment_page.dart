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
import 'package:scrollview_observer/scrollview_observer.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({
    super.key,
    required this.commentId,
    required this.rootNodeId,
    required this.rootNodeType,
    required this.rootNodeBy,
    required this.parentNodeType,
    required this.parentNodeId,
  });

  final String commentId;

  /// root node and root node type help to identify where to redirect
  /// discussion or post
  final String rootNodeId;
  final DokiNodeType rootNodeType;

  /// cognito user id for storing media items
  final String rootNodeBy;

  /// parents details can be same as root node details
  /// only required with comment replies for notifications
  final String parentNodeId;
  final DokiNodeType parentNodeType;

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final UserGraph graph = UserGraph();
  late final commentKey = generateCommentNodeKey(widget.commentId);

  late final DokiNodeType rootNodeType = widget.rootNodeType;
  late final String rootNodeId = widget.rootNodeId;
  late final String rootNodeBy = widget.rootNodeBy;
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  late final DokiNodeType parentNodeType = widget.parentNodeType;
  late final String parentNodeId = widget.parentNodeId;

  final ScrollController controller = ScrollController();
  late SliverObserverController observerController;

  @override
  void initState() {
    super.initState();
    observerController = SliverObserverController(
      controller: controller,
    )..cacheJumpIndexOffset = true;
  }

  @override
  void dispose() {
    observerController.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool invalidNode = rootNodeType == DokiNodeType.user;
    bool isCommentReply = parentNodeType == DokiNodeType.comment;

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

    final scrollCacheHeight = MediaQuery.sizeOf(context).height * 2;

    return Scaffold(
      appBar: AppBar(
        title: isCommentReply
            ? const Text("Comment reply")
            : const Text("Comment"),
        actions: [
          TextButton(
            onPressed: () {
              // redirect to correct page
              if (parentNodeType == DokiNodeType.post) {
                // go to post page
                context.pushReplacementNamed(
                  RouterConstants.userPost,
                  pathParameters: {
                    "postId": parentNodeId,
                  },
                );
              }

              if (parentNodeType == DokiNodeType.comment) {
                // go to comment page
                context.pushReplacementNamed(
                  RouterConstants.comment,
                  pathParameters: {
                    "userId": rootNodeBy,
                    "parentNodeType": rootNodeType.name,
                    "parentNodeId": rootNodeId,
                    "commentId": parentNodeId,
                    "rootNodeType": rootNodeType.name,
                    "rootNodeId": rootNodeId,
                  },
                );
              }
            },
            child: Text("Go to ${widget.parentNodeType.name} "),
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
            fetchReply: !isCommentReply,
          )),
        child: BlocConsumer<RootNodeBloc, RootNodeState>(
          listenWhen: (previousState, state) {
            return state is LoadErrorState;
          },
          listener: (context, state) {
            if (state is LoadErrorState) showError(state.message);
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
                  rootNodeId: rootNodeId,
                  rootNodeCreatedBy: rootNodeBy,
                  targetByUser: getUsernameFromUserKey(comment.commentBy),
                  rootNodeType: rootNodeType,
                  commentTargetId: isCommentReply ? parentNodeId : comment.id,
                  commentTargetNodeType:
                      isCommentReply ? parentNodeType : DokiNodeType.comment,
                  commentTargetNodeBy:
                      getUsernameFromUserKey(comment.commentBy),
                  controller: observerController,
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final userActionBloc = context.read<UserActionBloc>();
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
                          showError(state.message);
                          return;
                        }

                        userActionBloc.add(UserActionPrimaryNodeRefreshEvent(
                          nodeId: widget.commentId,
                        ));
                      },
                      child: BlocListener<UserActionBloc, UserActionState>(
                        listenWhen: (previousState, state) {
                          return state is UserActionNewCommentState &&
                              state.nodeId == comment.id;
                        },
                        listener: (context, state) {
                          controller.animateTo(
                            controller.position.maxScrollExtent,
                            duration: const Duration(
                              milliseconds: Constants.maxScrollDuration,
                            ),
                            curve: Curves.fastOutSlowIn,
                          );
                        },
                        child: repliesLoading || repliesError || isCommentReply
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  spacing: Constants.gap * 2,
                                  children: [
                                    CommentWidget(
                                      commentKey: commentKey,
                                      parentNodeId: comment.id,
                                      isReplyPage: isCommentReply,
                                    ),
                                    if (!isCommentReply)
                                      repliesError
                                          ? SizedBox(
                                              height: Constants.height * 5,
                                              child: StyledText.error(
                                                  state.message),
                                            )
                                          : const SizedBox(
                                              height: Constants.height * 5,
                                              child: Center(
                                                child: SmallLoadingIndicator(),
                                              ),
                                            ),
                                  ],
                                ),
                              )
                            : SliverViewObserver(
                                controller: observerController,
                                child: CustomScrollView(
                                  controller: controller,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
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
                                    BlocBuilder<UserActionBloc,
                                        UserActionState>(
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
                    ),
                  ),
                  if (!isCommentReply) const CommentInput(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
