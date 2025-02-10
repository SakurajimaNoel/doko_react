import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/widgets/comment/comment_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/widgets/comment/comment_list.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final UserGraph graph = UserGraph();
  late final postKey = generatePostNodeKey(widget.postId);
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  final ScrollController controller = ScrollController();

  Future<void> handlePostRefreshEvent() async {
    context.read<UserActionBloc>().add(UserActionPrimaryNodeRefreshEvent(
          nodeId: widget.postId,
        ));
  }

  void showToastError(String message) {
    showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final scrollCacheHeight = MediaQuery.sizeOf(context).height * 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<RootNodeBloc>()
          ..add(PostLoadEvent(
            details: GetNodeInput(
              nodeId: widget.postId,
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
            bool commentsLoading = state is SecondaryLoadingState;

            bool postError = state is RootNodeErrorState;
            bool commentError = state is SecondaryNodeErrorState;

            if (loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (postError) {
              return Center(
                child: StyledText.error(state.message),
              );
            }

            final PostEntity post = graph.getValueByKey(postKey)! as PostEntity;
            final UserEntity user =
                graph.getValueByKey(post.createdBy)! as UserEntity;

            return ChangeNotifierProvider(
              create: (BuildContext context) {
                return NodeCommentProvider(
                  focusNode: FocusNode(),
                  rootNodeId: post.id,
                  rootNodeCreatedBy: user.userId,
                  targetByUser: getUsernameFromUserKey(post.createdBy),
                  commentTargetId: post.id,
                  rootNodeType: DokiNodeType.post,
                  commentTargetNodeType: DokiNodeType.post,
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

                        context.read<RootNodeBloc>().add(PostRefreshEvent(
                              details: GetNodeInput(
                                nodeId: widget.postId,
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

                        handlePostRefreshEvent();
                      },
                      child: BlocListener<UserActionBloc, UserActionState>(
                        listenWhen: (previousState, state) {
                          return state is UserActionNewCommentState &&
                              state.nodeId == post.id;
                        },
                        listener: (context, state) {
                          final double offset =
                              post.content.isNotEmpty ? 150 : 0;

                          controller.animateTo(
                            offset,
                            duration: const Duration(
                              milliseconds: Constants.maxScrollDuration,
                            ),
                            curve: Curves.fastOutSlowIn,
                          );
                        },
                        child: commentError || commentsLoading
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  spacing: Constants.gap * 2,
                                  children: [
                                    PostWidget(
                                      postKey: postKey,
                                    ),
                                    commentError
                                        ? SizedBox(
                                            height: Constants.height * 5,
                                            child:
                                                StyledText.error(state.message),
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
                            : CustomScrollView(
                                controller: controller,
                                physics: const AlwaysScrollableScrollPhysics(),
                                cacheExtent: scrollCacheHeight,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: PostWidget(
                                      postKey: postKey,
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: Constants.gap * 2,
                                    ),
                                  ),
                                  BlocBuilder<UserActionBloc, UserActionState>(
                                    buildWhen: (previousState, state) {
                                      return state
                                              is UserActionPrimaryNodeRefreshState &&
                                          state.nodeId == post.id;
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
                                        parentNodeId: widget.postId,
                                        parentNodeType: DokiNodeType.post,
                                        key: ObjectKey({
                                          "postId": post.id,
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
