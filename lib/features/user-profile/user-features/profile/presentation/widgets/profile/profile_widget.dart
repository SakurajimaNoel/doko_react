import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/bottom-nav/bottom_nav_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  List<Widget> appBarActions() {
    final currTheme = Theme.of(context).colorScheme;

    if (!self) {
      return [
        TextButton(
          onPressed: handleUserProfileShare,
          // icon: const Icon(Icons.share),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            // padding: const EdgeInsets.symmetric(
            //   vertical: Constants.padding * 0.5,
            //   horizontal: Constants.padding * 0.75,
            // ),

            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Share",
            style: TextStyle(
              color: currTheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: Constants.fontSize,
            ),
          ),
        ),
      ];
    }

    return [
      IconButton(
        onPressed: () {
          context.pushNamed(RouterConstants.settings);
        },
        color: currTheme.onSurface,
        icon: const Icon(
          Icons.settings,
        ),
        tooltip: "Settings",
      ),
      const SignOutButton(),
    ];
  }

  Widget userProfileAction(CompleteUserEntity user) {
    if (self) {
      return Wrap(
        spacing: Constants.gap * 2,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: Constants.gap * 2,
        children: [
          FilledButton.icon(
            onPressed: () {
              // go to edit page
              context.pushNamed<String>(
                RouterConstants.editProfile,
              );
            },
            label: const Text("Edit"),
            icon: const Icon(Icons.edit_note),
          ),
          FilledButton.tonalIcon(
            onPressed: handleUserProfileShare,
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
          username: username,
        );
      }

      return UserToUserRelationWidget(
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
    final width = MediaQuery.sizeOf(context).width;
    final height = width * (1 / Constants.profile);

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
                    graph.getValueByKey(key)! is! CompleteUserEntity;

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
                  var initUser = graph.getValueByKey(key)! as UserEntity;

                  return Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: height,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                initUser.profilePicture.bucketPath.isNotEmpty
                                    ? CachedNetworkImage(
                                        memCacheHeight:
                                            Constants.profileCacheHeight,
                                        cacheKey:
                                            initUser.profilePicture.bucketPath,
                                        imageUrl:
                                            initUser.profilePicture.accessURI,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: SmallLoadingIndicator.small(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        height: height,
                                      )
                                    : Container(
                                        color: currTheme.onSecondary,
                                        child: Icon(
                                          Icons.person,
                                          size: height,
                                        ),
                                      ),
                                Container(
                                  padding: const EdgeInsets.only(
                                    top: Constants.padding * 2,
                                    bottom: Constants.padding,
                                    left: Constants.padding,
                                    right: Constants.padding,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        currTheme.surface
                                            .withValues(alpha: 0.75),
                                        currTheme.surface
                                            .withValues(alpha: 0.75),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Heading(
                                            initUser.username,
                                            size: Constants.heading4,
                                          ),
                                          Row(
                                            spacing: Constants.gap,
                                            children: appBarActions(),
                                          ),
                                        ],
                                      ),
                                      Heading.left(
                                        initUser.name,
                                        size: Constants.heading3,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(Constants.padding),
                            child: Stack(
                              fit: StackFit.loose,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth >
                                        Constants.userRelationWidth) {
                                      return UserToUserRelationWidget.label(
                                        username: username,
                                        disabled: true,
                                      );
                                    }

                                    return UserToUserRelationWidget(
                                      key: ValueKey(
                                          "$username-relation-without-label"),
                                      username: username,
                                      disabled: true,
                                    );
                                  },
                                ),
                                Container(
                                  color: currTheme.surface.withValues(
                                    alpha: 0.75,
                                  ),
                                  height: Constants.height * 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  );
                }

                if (state is ProfileLoading || state is ProfileInitial) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return RefreshIndicator(
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
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: height,
                        title: Heading(
                          username,
                          color: currTheme.onSurface,
                          size: Constants.heading4,
                        ),
                        actionsPadding: const EdgeInsets.symmetric(
                          horizontal: Constants.gap,
                        ),
                        actions: [
                          Row(
                            spacing: Constants.gap,
                            children: appBarActions(),
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: BlocBuilder<UserToUserActionBloc,
                              UserToUserActionState>(
                            buildWhen: (previousState, state) {
                              return (state
                                      is UserToUserActionUpdateProfileState &&
                                  state.username == username);
                            },
                            builder: (context, state) {
                              final user = graph.getValueByKey(key)!
                                  as CompleteUserEntity;
                              int nameLength = user.name.length;
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  user.profilePicture.bucketPath.isNotEmpty
                                      ? CachedNetworkImage(
                                          memCacheHeight:
                                              Constants.profileCacheHeight,
                                          cacheKey:
                                              user.profilePicture.bucketPath,
                                          imageUrl:
                                              user.profilePicture.accessURI,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child:
                                                SmallLoadingIndicator.small(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          height: height,
                                        )
                                      : Container(
                                          color: currTheme.onSecondary,
                                          child: Icon(
                                            Icons.person,
                                            size: height,
                                          ),
                                        ),
                                  ProfilePictureFilter(
                                    child: Heading.left(
                                      user.name,
                                      color: currTheme.onSurface,
                                      size: nameLength <= 15
                                          ? Constants.heading2
                                          : nameLength <= 20
                                              ? Constants.heading3
                                              : nameLength <= 25
                                                  ? Constants.heading4
                                                  : Constants.fontSize * 1.25,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
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
      child: _widget,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
