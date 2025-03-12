import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/pull-to-refresh/pull_to_refresh.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/widgets/comment/comment_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/widgets/comment/comment_list.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/polls/poll_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class PollPage extends StatefulWidget {
  const PollPage({
    super.key,
    required this.pollId,
  });

  final String pollId;

  @override
  State<PollPage> createState() => _PollPageState();
}

class _PollPageState extends State<PollPage> {
  final UserGraph graph = UserGraph();
  late final pollKey = generatePollNodeKey(widget.pollId);
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  final ScrollController controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    final scrollCacheHeight = MediaQuery.sizeOf(context).height * 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Poll"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<RootNodeBloc>()
          ..add(
            PollLoadEvent(
              details: GetNodeInput(
                nodeId: widget.pollId,
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

            bool pollError = state is RootNodeErrorState;
            bool commentError = state is SecondaryNodeErrorState;

            if (loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (pollError) {
              return Center(
                child: StyledText.error(state.message),
              );
            }

            final PollEntity poll = graph.getValueByKey(pollKey)! as PollEntity;
            final UserEntity user =
                graph.getValueByKey(poll.createdBy)! as UserEntity;

            return ChangeNotifierProvider(
              create: (BuildContext context) {
                return NodeCommentProvider(
                  focusNode: FocusNode(),
                  rootNodeId: poll.id,
                  rootNodeCreatedBy: user.userId,
                  targetByUser: getUsernameFromUserKey(poll.createdBy),
                  commentTargetId: poll.id,
                  rootNodeType: DokiNodeType.poll,
                  commentTargetNodeType: DokiNodeType.poll,
                  commentTargetNodeBy: getUsernameFromUserKey(poll.createdBy),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PullToRefresh(
                      onRefresh: () async {
                        final userActionBloc = context.read<UserActionBloc>();
                        Future pollBloc =
                            context.read<RootNodeBloc>().stream.first;

                        context.read<RootNodeBloc>().add(PollRefreshEvent(
                              details: GetNodeInput(
                                nodeId: widget.pollId,
                                username: username,
                              ),
                            ));

                        final RootNodeState state = await pollBloc;

                        if (state is PrimaryNodeRefreshErrorState) {
                          showError(state.message);
                          return;
                        }

                        userActionBloc.add(UserActionPrimaryNodeRefreshEvent(
                          nodeId: widget.pollId,
                        ));
                      },
                      child: BlocListener<UserActionBloc, UserActionState>(
                        listenWhen: (previousState, state) {
                          return state is UserActionNewCommentState &&
                              state.nodeId == poll.id;
                        },
                        listener: (context, state) {
                          final double offset = 150;

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
                                    PollWidget(
                                      pollKey: pollKey,
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
                                    child: PollWidget(
                                      pollKey: pollKey,
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
                                          state.nodeId == poll.id;
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
                                        parentNodeId: widget.pollId,
                                        parentNodeType: DokiNodeType.poll,
                                        key: ObjectKey({
                                          "pollId": poll.id,
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
