import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/provider/bottom-nav/bottom_nav_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/pull-to-refresh/pull_to_refresh.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/input/user_feed_input.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/presentation/bloc/user_feed_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/discussions/discussion_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/create/create_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/inbox/inbox_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/pending-requests/pending_requests_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/navigation/search/search_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/polls/poll_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserFeedPage extends StatefulWidget {
  const UserFeedPage({super.key});

  @override
  State<UserFeedPage> createState() => _UserFeedPageState();
}

class _UserFeedPageState extends State<UserFeedPage> {
  final graph = UserGraph();
  final userFeedKey = generateUserFeedKey();

  late final ScrollController controller;
  double forwardOffset = 0;
  double backwardOffset = 0;

  bool loading = false;
  @override
  void initState() {
    super.initState();

    controller = ScrollController();
    controller.addListener(handleScroll);
  }

  void handleScroll() {
    final currentOffset = controller.offset;
    final forwardDiff = (currentOffset - forwardOffset).abs();
    final backwardDiff = (currentOffset - backwardOffset).abs();

    // handle bottom nav hide
    if (controller.position.userScrollDirection == ScrollDirection.forward) {
      backwardOffset = currentOffset;
      if (forwardDiff > Constants.scrollOffset &&
          context.read<BottomNavProvider>().hide) {
        context.read<BottomNavProvider>().showBottomNav();
        forwardOffset = currentOffset;
      }
    } else {
      forwardOffset = currentOffset;
      if (backwardDiff > Constants.scrollOffset &&
          context.read<BottomNavProvider>().show) {
        context.read<BottomNavProvider>().hideBottomNav();
        backwardOffset = currentOffset;
      }
    }
  }

  @override
  void dispose() {
    controller.removeListener(handleScroll);
    super.dispose();
  }

  Widget buildTimelineItems(BuildContext context, int index) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final Nodes userFeed = graph.getValueByKey(userFeedKey)! as Nodes;

    if (index >= userFeed.items.length) {
      /// fetch more posts if exits
      if (!userFeed.pageInfo.hasNextPage) {
        String message = "You have reached the end.";
        if (userFeed.items.isEmpty) message = "Add friends to see user posts.";
        return Center(
          child: Text(message),
        );
      }

      // fetch more post
      if (!loading) {
        loading = true;
        context.read<UserFeedBloc>().add(UserFeedGetEvent(
              details: UserFeedInput(
                username: username,
                cursor: userFeed.pageInfo.endCursor ?? "",
              ),
            ));
      }

      return const Center(
        child: SmallLoadingIndicator(),
      );
    }

    String nodeKey = userFeed.items[index];
    DokiNodeType? nodeType = getNodeTypeFromKey(nodeKey);
    if (nodeType == null) {
      return const SizedBox.shrink();
    }

    if (nodeType == DokiNodeType.post) {
      return PostWidget(
        key: ValueKey("timeline-$nodeKey"),
        postKey: nodeKey,
      );
    }

    if (nodeType == DokiNodeType.discussion) {
      return DiscussionWidget(
        key: ValueKey("timeline-$nodeKey"),
        discussionKey: nodeKey,
      );
    }

    return PollWidget(
      key: ValueKey("timeline-$nodeKey"),
      pollKey: nodeKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final scrollCacheHeight = MediaQuery.sizeOf(context).height * 2;
    bool useSideNavRail = MediaQuery.sizeOf(context).width >= Constants.compact;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doki"),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: Constants.gap,
        ),
        actions: useSideNavRail
            ? null
            : [
                const CreateWidget(),
                const SearchWidget(),
                const PendingRequestsWidget(),
                const InboxWidget(),
              ],
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<UserFeedBloc>()
          ..add(UserFeedGetEvent(
            details: UserFeedInput(
              username: username,
              cursor: "",
            ),
          )),
        child: BlocConsumer<UserFeedBloc, UserFeedState>(
          listenWhen: (previousState, state) {
            return state is UserFeedGetResponseState;
          },
          listener: (context, state) async {
            loading = false;

            if (state is UserFeedGetResponseErrorState) {
              showError(state.message);
            }

            context.read<RealTimeBloc>().add(RealTimeInboxGetEvent(
                    details: InboxQueryInput(
                  cursor: "",
                  username: username,
                )));
          },
          buildWhen: (previousState, state) {
            return state is UserFeedGetResponseState;
          },
          builder: (context, state) {
            bool initialLoading = state is UserFeedLoading;
            final userFeed = graph.getValueByKey(userFeedKey);

            return PullToRefresh(
              onRefresh: () async {
                final userFeedBloc = context.read<UserFeedBloc>();
                Future userFeedBlocState = userFeedBloc.stream.first;

                userFeedBloc.add(UserFeedGetEvent(
                  details: UserFeedInput(
                    username: username,
                    cursor: "",
                  ),
                ));

                await userFeedBlocState;
              },
              child: CustomScrollView(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                cacheExtent: scrollCacheHeight,
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.only(
                      top: Constants.padding,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.padding,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: UserWidget.preview(
                        userKey: generateUserNodeKey(username),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: Constants.padding,
                    ),
                  ),
                  if (initialLoading)
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: Constants.height * 20,
                        child: Center(
                          child: SmallLoadingIndicator(),
                        ),
                      ),
                    )
                  else
                    (userFeed is! Nodes)
                        ? const SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "Looks like there is nothing to show.",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : SliverList.separated(
                            itemCount: userFeed.items.length + 1,
                            itemBuilder: buildTimelineItems,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                height: Constants.gap * 1.75,
                              );
                            },
                          ),
                  const SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: Constants.padding,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
