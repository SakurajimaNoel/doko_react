import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error_text.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/widgets/friends/friend_container_profile_widget.dart';
import 'package:doko_react/features/User/widgets/posts/post_container_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/configs/router/router_constants.dart';
import '../../../core/data/auth.dart';
import '../../../core/helpers/enum.dart';
import '../../../core/widgets/loader.dart';
import '../data/graphql_queries/friend_relation.dart';
import '../data/services/user_graphql_service.dart';

class ProfileWidget extends StatefulWidget {
  final String userId;
  final bool self;

  const ProfileWidget({
    super.key,
    required this.userId,
    this.self = false,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late final bool _self;
  late final String _userId;
  late final UserProvider _userProvider;

  final UserGraphqlService _userGraphqlService = UserGraphqlService();

  bool _loading = true;
  CompleteUserModel? _user;

  @override
  void initState() {
    super.initState();

    _userId = widget.userId;
    _self = widget.self;

    _userProvider = context.read<UserProvider>();

    _fetchCompleteUser();
  }

  Future<void> _fetchCompleteUser({bool force = false}) async {
    if (_userId.isEmpty) return;

    String userId = "0abbcfed-04b9-4f54-9c6b-46fadbc51442";
    var completeUser = await _userGraphqlService.getCompleteUser(
      userId,
      force: force,
      currentUserId: _userProvider.id,
    );

    if (_loading) {
      setState(() {
        _loading = false;
      });
    }

    if (completeUser.status == ResponseStatus.error ||
        completeUser.user == null) {
      return;
    }

    var user = completeUser.user!;
    var status = FriendRelation.getFriendRelationStatus(
        user.friendRelationDetail, _userProvider.id);
    safePrint(status.toString());

    if (_self) {
      _userProvider.updateUser(updatedUser: user);
    }
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  List<Widget> _appBarActions() {
    if (!_self) {
      return [];
    }
    var currScheme = Theme.of(context).colorScheme;

    return [
      IconButton(
        onPressed: () {
          context.goNamed(RouterConstants.settings);
        },
        icon: const Icon(Icons.settings),
        tooltip: "Settings",
      ),
      TextButton(
        onPressed: () {
          AuthenticationActions.signOutUser();
        },
        child: Text(
          "Sign out",
          style: TextStyle(
            color: currScheme.error,
          ),
        ),
      )
    ];
  }

  Widget _noUser() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: _appBarActions(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchCompleteUser(force: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: Constants.padding,
            right: Constants.padding,
            top: MediaQuery.sizeOf(context).height * 0.4,
          ),
          children: const [
            ErrorText(
              "Oops! Something went wrong.",
              fontSize: Constants.fontSize,
            ),
            SizedBox(
              height: Constants.height * 0.5,
            ),
            Text(
              "Pull to refresh",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Constants.smallFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userProfileAction() {
    if (_self) {
      return OutlinedButton(
        onPressed: () async {
          // go to edit page
          Map<String, dynamic> data = {
            "bio": _user!.bio,
          };
          String? newBio = await context
              .pushNamed<String>(RouterConstants.editProfile, extra: data);
          if (_user!.bio != newBio) {
            setState(() {
              _user!.bio = newBio ?? "";
            });
          }
        },
        child: const Text("Edit"),
      );
    }

    return OutlinedButton(
      onPressed: () {},
      child: const Text("Add"),
    );
  }

  Widget _loader() {
    var currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _self ? Text(_userProvider.username) : const Text("Profile"),
        actions: [
          if (_self) ...[
            IconButton(
              onPressed: () {
                context.goNamed(RouterConstants.settings);
              },
              icon: const Icon(Icons.settings),
              tooltip: "Settings",
            ),
            TextButton(
              onPressed: () {
                AuthenticationActions.signOutUser();
              },
              child: Text(
                "Sign out",
                style: TextStyle(
                  color: currTheme.error,
                ),
              ),
            )
          ]
        ],
      ),
      body: const Loader(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;
    var userProvider = context.watch<UserProvider>();

    var user = _user;

    if (_loading) {
      return _loader();
    }

    if (user == null) {
      return _noUser();
    }

    if (_self) {
      user.profilePicture = userProvider.profilePicture;
      user.signedProfilePicture = userProvider.signedProfilePicture;
      user.name = userProvider.name;
    }

    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        notificationPredicate: (notification) {
          // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
          int depth;
          if (user.postsInfo.posts.isNotEmpty ||
              user.friendsInfo.friends.isNotEmpty) {
            depth = 2;
          } else {
            depth = 0;
          }
          return notification.depth == depth;
        },
        onRefresh: () async {
          await _fetchCompleteUser(force: true);
        },
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: false,
                pinned: true,
                expandedHeight: Constants.expandedAppBarHeight,
                title: Text(user.username),
                actions: _appBarActions(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      user.profilePicture.isNotEmpty
                          ? CachedNetworkImage(
                              memCacheHeight: Constants.profileCacheHeight,
                              cacheKey: user.profilePicture,
                              imageUrl: user.signedProfilePicture,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              height: Constants.expandedAppBarHeight,
                            )
                          : Container(
                              color: currTheme.onSecondary,
                              child: const Icon(
                                Icons.person,
                                size: Constants.expandedAppBarHeight,
                              ),
                            ),
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: Constants.padding,
                          left: Constants.padding,
                        ),
                        alignment: Alignment.bottomLeft,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              currTheme.surface.withOpacity(0.5),
                              currTheme.surface.withOpacity(0.25),
                              currTheme.surface.withOpacity(0.25),
                              currTheme.surface.withOpacity(0.5),
                            ],
                          ),
                        ),
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
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user.bio.isNotEmpty) ...[
                        Text(user.bio),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                      _userProfileAction(),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(
                        text: "Posts",
                      ),
                      Tab(
                        text: "Friends",
                      ),
                    ],
                  ),
                ),
              )
            ];
          },
          body: TabBarView(
            children: [
              PostContainerProfileWidget(
                postInfo: user.postsInfo,
                user: user,
                key: ValueKey(user.profilePicture),
              ),
              FriendContainerProfileWidget(
                friendInfo: user.friendsInfo,
                user: user,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
