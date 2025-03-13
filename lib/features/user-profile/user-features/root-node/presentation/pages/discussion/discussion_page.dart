import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/pull-to-refresh/pull_to_refresh.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/discussion/discussion_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/widgets/comment/comment_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/widgets/comment/comment_list.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/discussions/discussion_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({
    super.key,
    required this.discussionId,
  });

  final String discussionId;

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final UserGraph graph = UserGraph();
  late final discussionKey = generateDiscussionNodeKey(widget.discussionId);
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final scrollCacheHeight = MediaQuery.sizeOf(context).height * 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussion"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<RootNodeBloc>()
          ..add(
            DiscussionLoadEvent(
              details: GetNodeInput(
                nodeId: widget.discussionId,
                username: username,
              ),
            ),
          ),
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
            bool commentsLoading = state is SecondaryLoadingState;

            bool discussionError = state is RootNodeErrorState;
            bool commentError = state is SecondaryNodeErrorState;

            if (loading) {
              return const Center(
                child: LoadingWidget(),
              );
            }
            if (discussionError) {
              return Center(
                child: StyledText.error(state.message),
              );
            }

            final DiscussionEntity discussion =
                graph.getValueByKey(discussionKey)! as DiscussionEntity;
            final UserEntity user =
                graph.getValueByKey(discussion.createdBy)! as UserEntity;

            return ChangeNotifierProvider(
              create: (BuildContext context) {
                return NodeCommentProvider(
                  focusNode: FocusNode(),
                  rootNodeId: discussion.id,
                  rootNodeCreatedBy: user.userId,
                  targetByUser: getUsernameFromUserKey(discussion.createdBy),
                  commentTargetId: discussion.id,
                  rootNodeType: DokiNodeType.discussion,
                  commentTargetNodeType: DokiNodeType.discussion,
                  commentTargetNodeBy:
                      getUsernameFromUserKey(discussion.createdBy),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PullToRefresh(
                      onRefresh: () async {
                        final userActionBloc = context.read<UserActionBloc>();
                        Future discussionBloc =
                            context.read<RootNodeBloc>().stream.first;

                        context.read<RootNodeBloc>().add(DiscussionRefreshEvent(
                              details: GetNodeInput(
                                nodeId: widget.discussionId,
                                username: username,
                              ),
                            ));

                        final RootNodeState state = await discussionBloc;

                        if (state is PrimaryNodeRefreshErrorState) {
                          showError(state.message);
                          return;
                        }

                        userActionBloc.add(UserActionPrimaryNodeRefreshEvent(
                          nodeId: widget.discussionId,
                        ));
                      },
                      child: BlocListener<UserActionBloc, UserActionState>(
                        listenWhen: (previousState, state) {
                          return state is UserActionNewCommentState &&
                              state.nodeId == discussion.id;
                        },
                        listener: (context, state) {
                          final double offset =
                              discussion.media.isNotEmpty ? 150 : 0;

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
                                child: CompactBox(
                                  child: Column(
                                    spacing: Constants.gap * 2,
                                    children: [
                                      DiscussionWidget(
                                        discussionKey: discussionKey,
                                      ),
                                      commentError
                                          ? SizedBox(
                                              height: Constants.height * 5,
                                              child: StyledText.error(
                                                  state.message),
                                            )
                                          : const SizedBox(
                                              height: Constants.height * 5,
                                              child: Center(
                                                child: LoadingWidget.small(),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              )
                            : CustomScrollView(
                                controller: controller,
                                physics: const AlwaysScrollableScrollPhysics(),
                                cacheExtent: scrollCacheHeight,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: CompactBox(
                                      child: DiscussionWidget(
                                        discussionKey: discussionKey,
                                      ),
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
                                          state.nodeId == discussion.id;
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
                                        parentNodeId: widget.discussionId,
                                        parentNodeType: DokiNodeType.discussion,
                                        key: ObjectKey({
                                          "discussionId": discussion.id,
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
