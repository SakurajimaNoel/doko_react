import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/authentication/presentation/widgets/public/sign-out-button/sign_out_button.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/widgets/posts/profile_post.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_to_user_relation_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
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

  final UserGraph graph = UserGraph();

  @override
  void initState() {
    super.initState();

    username = widget.username;
    currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;

    self = username == currentUsername;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  List<Widget> appBarActions() {
    if (!self) {
      return [];
    }

    return [
      IconButton(
        onPressed: () {
          context.pushNamed(RouterConstants.settings);
        },
        icon: const Icon(Icons.settings),
        tooltip: "Settings",
      ),
      const SignOutButton()
    ];
  }

  Widget userProfileAction(CompleteUserEntity user) {
    if (self) {
      return FilledButton.tonalIcon(
        onPressed: () {
          // go to edit page
          context.pushNamed<String>(
            RouterConstants.editProfile,
          );
        },
        label: const Text("Edit"),
        icon: const Icon(Icons.edit_note),
      );
    }

    return UserToUserRelationWidget.label(
      username: username,
    );
  }

  Widget userProfileInfo(String key) {
    var currTheme = Theme.of(context).colorScheme;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionUpdateUserAcceptedFriendsListState &&
                (self || state.username == username)) ||
            (self && state is UserActionNewPostState) ||
            (state is UserActionUserRefreshState && state.username == username);
      },
      builder: (context, state) {
        final user = graph.getValueByKey(key)! as CompleteUserEntity;

        return Row(
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
                    Icon(
                      Icons.calendar_view_month,
                      color: currTheme.primary,
                    ),
                    const SizedBox(
                      width: Constants.gap * 0.5,
                    ),
                    Text(
                      "Posts: ${displayNumberFormat(user.postsCount)}",
                      style: TextStyle(
                        color: currTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
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
              label: Text("Friends: ${displayNumberFormat(user.friendsCount)}"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    GetProfileInput details = GetProfileInput(
      username: username,
      currentUsername: currentUsername,
    );

    final key = generateUserNodeKey(username);

    final currTheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final height = width * (1 / Constants.profile);

    return Scaffold(
      body: BlocProvider(
        create: (context) => serviceLocator<ProfileBloc>()
          ..add(
            GetUserProfileEvent(
              userDetails: details,
            ),
          ),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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

            return RefreshIndicator(
              onRefresh: () async {
                Future profileBloc = context.read<ProfileBloc>().stream.first;

                context.read<ProfileBloc>().add(GetUserProfileRefreshEvent(
                      userDetails: details,
                    ));

                final ProfileState state = await profileBloc;

                if (state is ProfileRefreshError) {
                  showMessage(state.message);
                } else {
                  // trigger ui rebuilds
                  if (mounted) {
                    context
                        .read<UserActionBloc>()
                        .add(UserActionUserRefreshEvent(
                          username: username,
                        ));
                  }
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: height,
                    title: Text(username),
                    actions: appBarActions(),
                    flexibleSpace: FlexibleSpaceBar(
                      background: BlocBuilder<UserActionBloc, UserActionState>(
                        buildWhen: (previousState, state) {
                          return (self && state is UserActionUpdateProfile) ||
                              (state is UserActionUserRefreshState &&
                                  state.username == username);
                        },
                        builder: (context, state) {
                          final user =
                              graph.getValueByKey(key)! as CompleteUserEntity;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              user.profilePicture.bucketPath.isNotEmpty
                                  ? CachedNetworkImage(
                                      memCacheHeight:
                                          Constants.profileCacheHeight,
                                      cacheKey: user.profilePicture.bucketPath,
                                      imageUrl: user.profilePicture.accessURI,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
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
                                child: Text(
                                  user.name,
                                  style: TextStyle(
                                    color: currTheme.onSurface,
                                    fontSize: Constants.heading2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(Constants.padding),
                      child: BlocBuilder<UserActionBloc, UserActionState>(
                        buildWhen: (previousState, state) {
                          return (self && state is UserActionUpdateProfile) ||
                              (state is UserActionUserRefreshState &&
                                  state.username == username);
                        },
                        builder: (context, state) {
                          final user =
                              graph.getValueByKey(key)! as CompleteUserEntity;
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
                  ProfilePost(
                    username: username,
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
