import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/bottom-nav/bottom_nav_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/heading/auto_heading.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
import 'package:doko_react/core/widgets/pull-to-refresh/pull_to_refresh.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/authentication/presentation/widgets/public/sign-out-button/sign_out_button.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/widgets/timeline/timeline.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_to_user_relation_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

part "profile_user_widget.dart";

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late final bool self;
  late final String username;
  late final String currentUsername;

  double forwardOffset = 0;
  double backwardOffset = 0;

  final UserGraph graph = UserGraph();
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();

    username = widget.username;
    currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;

    self = username == currentUsername;

    controller = ScrollController();
    controller.addListener(handleScroll);
  }

  void handleScroll() {
    String currentRoute = GoRouter.of(context).currentRouteName ?? "";

    if (currentRoute != RouterConstants.profile) return;

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

  void handleUserProfileShare() {
    Share.share(
      context: context,
      subject: MessageSubject.dokiUser,
      nodeIdentifier: username,
    );
  }

  Widget userProfileAction(
    UserEntity user, {
    bool disable = false,
  }) {
    if (self) {
      return Wrap(
        spacing: Constants.gap * 2,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: Constants.gap * 2,
        children: [
          FilledButton.icon(
            onPressed: disable
                ? null
                : () {
                    // go to edit page
                    context.pushNamed<String>(
                      RouterConstants.editProfile,
                    );
                  },
            label: const Text("Edit"),
            icon: const Icon(Icons.edit_note),
          ),
          FilledButton.tonalIcon(
            onPressed: disable ? null : handleUserProfileShare,
            icon: const Icon(Icons.share),
            label: const Text("Share"),
          ),
          ElevatedButton(
            onPressed: () {
              context.pushNamed<String>(
                RouterConstants.token,
              );
            },
            child: const Text("Token"),
          ),
        ],
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > Constants.userRelationWidth) {
        return UserToUserRelationWidget.label(
          key: ValueKey("$username-relation-with-label"),
          disabled: disable,
          username: username,
        );
      }

      return UserToUserRelationWidget(
        disabled: disable,
        key: ValueKey("$username-relation-without-label"),
        username: username,
      );
    });
  }

  Widget userProfileInfo(String key) {
    var currTheme = Theme.of(context).colorScheme;
    final user = graph.getValueByKey(key)! as CompleteUserEntity;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        spacing: Constants.gap * 1.5,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Material(
            shape: Border(
              bottom: BorderSide(
                color: currTheme.primary,
                width: Constants.sliverBorder * 3,
              ),
            ),
            child: SizedBox(
              height: double.infinity,
              child: Row(
                children: [
                  BlocBuilder<UserActionBloc, UserActionState>(
                    buildWhen: (previousState, state) {
                      return (state is UserActionNewPostState &&
                          state.username == username);
                    },
                    builder: (context, state) {
                      return Text(
                        "Timeline",
                        style: TextStyle(
                          color: currTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // friends
          BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
            buildWhen: (previousState, state) {
              return (state
                      is UserToUserActionUpdateUserAcceptedFriendsListState &&
                  (self || state.username == username));
            },
            builder: (context, state) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  iconColor: currTheme.secondary,
                  foregroundColor: currTheme.secondary,
                ),
                onPressed: () {
                  context.pushNamed(
                    RouterConstants.profileFriends,
                    pathParameters: {
                      "username": username,
                    },
                  );
                },
                icon: const Icon(Icons.group),
                label:
                    Text("Friends: ${displayNumberFormat(user.friendsCount)}"),
              );
            },
          ),

          // pages
          BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
            // todo: handle this
            buildWhen: (previousState, state) {
              return (state
                      is UserToUserActionUpdateUserAcceptedFriendsListState &&
                  (self || state.username == username));
            },
            builder: (context, state) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  iconColor: currTheme.secondary,
                  foregroundColor: currTheme.secondary,
                ),
                onPressed: () {
                  // context.pushNamed(
                  //   RouterConstants.profilePages,
                  //   pathParameters: {
                  //     "username": username,
                  //   },
                  // );
                },
                icon: const Icon(Icons.pages),
                label: Text("Pages: ${displayNumberFormat(user.pageCount)}"),
              );
            },
          ),
          // posts
          BlocBuilder<UserActionBloc, UserActionState>(
            buildWhen: (previousState, state) {
              return (state is UserActionNewPostState &&
                  state.username == username);
            },
            builder: (context, state) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  iconColor: currTheme.secondary,
                  foregroundColor: currTheme.secondary,
                ),
                onPressed: () {
                  context.pushNamed(
                    RouterConstants.profilePosts,
                    pathParameters: {
                      "username": username,
                    },
                  );
                },
                icon: const Icon(Icons.calendar_view_day_rounded),
                label: Text(
                  "Posts: ${displayNumberFormat(user.postsCount)}",
                ),
              );
            },
          ),
          // discussions
          BlocBuilder<UserActionBloc, UserActionState>(
            buildWhen: (previousState, state) {
              return (state is UserActionNewDiscussionState &&
                  (self || state.username == username));
            },
            builder: (context, state) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  iconColor: currTheme.secondary,
                  foregroundColor: currTheme.secondary,
                ),
                onPressed: () {
                  context.pushNamed(
                    RouterConstants.profileDiscussions,
                    pathParameters: {
                      "username": username,
                    },
                  );
                },
                icon: const Icon(Icons.text_snippet),
                label: Text(
                    "Discussions: ${displayNumberFormat(user.discussionCount)}"),
              );
            },
          ),
          // polls
          BlocBuilder<UserActionBloc, UserActionState>(
            buildWhen: (previousState, state) {
              return (state is UserActionNewPollState &&
                  (self || state.username == username));
            },
            builder: (context, state) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  iconColor: currTheme.secondary,
                  foregroundColor: currTheme.secondary,
                ),
                onPressed: () {
                  context.pushNamed(
                    RouterConstants.profilePolls,
                    pathParameters: {
                      "username": username,
                    },
                  );
                },
                icon: const Icon(Icons.poll),
                label: Text("Polls: ${displayNumberFormat(user.pollCount)}"),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProfileNodesInput details = UserProfileNodesInput(
      username: username,
      currentUsername: currentUsername,
    );

    final key = generateUserNodeKey(username);
    final currTheme = Theme.of(context).colorScheme;

    final scrollCacheHeight = MediaQuery.sizeOf(context).height * 2;

    DateTime latestFetch = DateTime.now();

    return Scaffold(
      body: BlocProvider(
        create: (context) => serviceLocator<ProfileBloc>()
          ..add(
            GetUserProfileEvent(
              userDetails: details,
            ),
          ),
        child: BlocConsumer<UserToUserActionBloc, UserToUserActionState>(
          listenWhen: (previousState, state) {
            return state is UserToUserActionUserRefreshState &&
                state.username == username;
          },
          listener: (context, state) {
            latestFetch = DateTime.now();
          },
          buildWhen: (previousState, state) {
            return state is UserToUserActionUserRefreshState &&
                state.username == username;
          },
          builder: (context, state) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                bool isUserEntity = graph.containsKey(key) &&
                    graph.getValueByKey(key) is! CompleteUserEntity;

                if (state is ProfileError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: Constants.gap,
                      children: [
                        StyledText.error(state.message),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProfileBloc>().add(GetUserProfileEvent(
                                  userDetails: details,
                                ));
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (isUserEntity) {
                  var user = graph.getValueByKey(key)! as UserEntity;

                  return Stack(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: currTheme.surface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        position: DecorationPosition.foreground,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            _ProfileUserWidget(
                              username: username,
                              self: self,
                              onShare: handleUserProfileShare,
                            ),
                            SliverToBoxAdapter(
                              child: CompactBox(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(Constants.padding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      userProfileAction(
                                        user,
                                        disable: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Center(
                        child: LoadingWidget(),
                      ),
                    ],
                  );
                }

                if (state is ProfileLoading || state is ProfileInitial) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                }

                return PullToRefresh(
                  onRefresh: () async {
                    final userToUserActionBloc =
                        context.read<UserToUserActionBloc>();
                    Future profileBloc =
                        context.read<ProfileBloc>().stream.first;

                    context.read<ProfileBloc>().add(GetUserProfileRefreshEvent(
                          userDetails: details,
                        ));

                    final ProfileState state = await profileBloc;

                    if (state is ProfileRefreshError) {
                      showError(state.message);
                    } else {
                      // trigger ui rebuilds
                      userToUserActionBloc.add(UserToUserActionUserRefreshEvent(
                        username: username,
                      ));
                    }
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controller,
                    cacheExtent: scrollCacheHeight,
                    slivers: [
                      _ProfileUserWidget(
                        username: username,
                        self: self,
                        onShare: handleUserProfileShare,
                      ),
                      SliverToBoxAdapter(
                        child: CompactBox(
                          child: Padding(
                            padding: const EdgeInsets.all(Constants.padding),
                            child: BlocBuilder<UserToUserActionBloc,
                                UserToUserActionState>(
                              buildWhen: (previousState, state) {
                                return (state
                                        is UserToUserActionUpdateProfileState &&
                                    state.username == username);
                              },
                              builder: (context, state) {
                                final user = graph.getValueByKey(key)!
                                    as CompleteUserEntity;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (user.bio.isNotEmpty) ...[
                                      Text(user.bio),
                                      const SizedBox(
                                        height: Constants.gap,
                                      ),
                                    ],
                                    userProfileAction(user),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          userProfileInfo(key),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Constants.gap * 2,
                        ),
                      ),
                      Timeline(
                        username: username,
                        key: ObjectKey(latestFetch),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: Constants.gap * 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _widget;

  _SliverAppBarDelegate(this._widget);

  @override
  double get minExtent => Constants.sliverPersistentHeaderHeight;

  @override
  double get maxExtent => Constants.sliverPersistentHeaderHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: Constants.sliverBorder,
        ),
      ),
      child: Center(child: _widget),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
