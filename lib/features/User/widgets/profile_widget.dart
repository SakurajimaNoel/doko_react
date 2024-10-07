import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/loader/loader.dart';
import 'package:doko_react/features/User/data/graphql_queries/friend_relation.dart';
import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:doko_react/features/User/widgets/friends/friend_container_profile_widget.dart';
import 'package:doko_react/features/User/widgets/posts/post_container_profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  final String userId;

  const ProfileWidget({
    super.key,
    required this.userId,
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

    _userProvider = context.read<UserProvider>();

    _userId = widget.userId;
    _self = _userProvider.id == _userId;

    _fetchCompleteUser();
  }

  Future<void> _fetchCompleteUser() async {
    if (_userId.isEmpty) return;

    var completeUser = await _userGraphqlService.getCompleteUser(
      _userId,
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
          await _fetchCompleteUser();
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
      return FilledButton.tonalIcon(
        onPressed: () async {
          // go to edit page
          Map<String, dynamic> data = {
            "bio": _user!.bio,
          };
          String? newBio = await context.pushNamed<String>(
            RouterConstants.editProfile,
            extra: data,
          );
          if (_user!.bio != newBio) {
            setState(() {
              _user!.bio = newBio ?? "";
            });
          }
        },
        label: const Text("Edit"),
        icon: const Icon(Icons.edit_note),
      );
    }

    var status = FriendRelation.getFriendRelationStatus(
        _user!.friendRelationDetail, _userProvider.id);

    return _UserProfileAction(
      status: status,
      user: _user!,
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
    var width = MediaQuery.sizeOf(context).width;
    var height = width * (1 / Constants.profile);

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
      child: Scaffold(
        body: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                forceElevated: innerBoxIsScrolled,
                floating: false,
                pinned: true,
                expandedHeight: height,
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
                key: ValueKey("${user.username} posts"),
              ),
              FriendContainerProfileWidget(
                friendInfo: user.friendsInfo,
                user: user,
                key: ValueKey("${user.username} friends"),
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

class _UserProfileAction extends StatefulWidget {
  final FriendRelationStatus status;
  final CompleteUserModel user;

  const _UserProfileAction({
    required this.status,
    required this.user,
  });

  @override
  State<_UserProfileAction> createState() => _UserProfileActionState();
}

class _UserProfileActionState extends State<_UserProfileAction> {
  late FriendRelationStatus _status;
  late CompleteUserModel _user;

  late final UserProvider _userProvider;

  final UserGraphqlService _userGraphqlService = UserGraphqlService();
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    _status = widget.status;
    _user = widget.user;

    _userProvider = context.read<UserProvider>();
  }

  Future<void> _handleAdd() async {
    setState(() {
      _status = FriendRelationStatus.outgoingReq;
      _updating = true;
    });

    String requestedBy = _userProvider.id;
    String requestedTo = _user.id;

    var addResponse = await _userGraphqlService.userSendFriendRequest(
        requestedBy, requestedTo);
    setState(() {
      _updating = false;
    });

    if (addResponse == ResponseStatus.error) {
      setState(() {
        _status = FriendRelationStatus.unrelated;
      });
      String message = "can't send friend request to ${_user.name}";
      _handleError(message);
      return;
    }

    // success
    _user.friendRelationDetail = FriendConnectionDetail(
      requestedBy: requestedBy,
      status: FriendStatus.pending,
    );
  }

  Future<void> _handleCancel() async {
    var currentStatus = _status;
    var errorMessage =
        "can't cancel your request to ${_user.name}."; // outgoing req cancel

    switch (currentStatus) {
      case FriendRelationStatus.friends:
        errorMessage = "can't remove ${_user.name} from your friends.";
      case FriendRelationStatus.incomingReq:
        errorMessage = "can't remove ${_user.name}'s friend request.";
      default:
        errorMessage = "Oops! Something went wrong.";
    }

    setState(() {
      _status = FriendRelationStatus.unrelated;
      _updating = true;
    });

    String requestedBy = _user.friendRelationDetail!.requestedBy;
    String requestedTo =
        requestedBy == _userProvider.id ? _user.id : _userProvider.id;

    var cancelResponse = await _userGraphqlService.userRemoveFriendRelation(
        requestedBy, requestedTo);
    setState(() {
      _updating = false;
    });

    if (cancelResponse == ResponseStatus.error) {
      setState(() {
        _status = currentStatus;
      });
      _handleError(errorMessage);
      return;
    }

    // success
    _user.friendRelationDetail = null;
  }

  Future<void> _handleAccept() async {
    setState(() {
      _status = FriendRelationStatus.friends;
      _updating = true;
    });

    String requestedBy = _user.friendRelationDetail!.requestedBy;
    String requestedTo =
        requestedBy == _userProvider.id ? _user.id : _userProvider.id;

    var acceptResponse = await _userGraphqlService.userAcceptFriendRequest(
        requestedBy, requestedTo);

    setState(() {
      _updating = false;
    });

    if (acceptResponse == ResponseStatus.error) {
      setState(() {
        _status = FriendRelationStatus.incomingReq;
      });
      var message = "can't accept ${_user.name}'s friend request.";
      _handleError(message);
      return;
    }

    // success
    _user.friendRelationDetail!.updateStatus(FriendStatus.accepted);
  }

  void _handleError(String message) {
    var snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(
        milliseconds: 1500,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var currScheme = Theme.of(context).colorScheme;

    // unrelated
    if (_status == FriendRelationStatus.unrelated) {
      return FilledButton.tonalIcon(
        onPressed: _updating
            ? null
            : () {
                _handleAdd();
              },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text("Add"),
      );
    }

    // outgoing req
    if (_status == FriendRelationStatus.outgoingReq) {
      return FilledButton.tonalIcon(
        onPressed: _updating
            ? null
            : () {
                _handleCancel();
              },
        label: Text(
          "Cancel request",
          style: TextStyle(
            color: currScheme.onError,
          ),
        ),
        icon: Icon(
          Icons.close,
          color: currScheme.onError,
        ),
        style: FilledButton.styleFrom(
          backgroundColor: currScheme.error,
        ),
      );
    }

    // incoming req
    if (_status == FriendRelationStatus.incomingReq) {
      return Row(
        children: [
          FilledButton.tonalIcon(
            onPressed: _updating
                ? null
                : () {
                    _handleAccept();
                  },
            icon: const Icon(Icons.check),
            label: const Text("Accept"),
          ),
          const SizedBox(
            width: Constants.gap,
          ),
          FilledButton.tonalIcon(
            onPressed: _updating
                ? null
                : () {
                    _handleCancel();
                  },
            label: Text(
              "Cancel request",
              style: TextStyle(
                color: currScheme.onError,
              ),
            ),
            icon: Icon(
              Icons.close,
              color: currScheme.onError,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: currScheme.error,
            ),
          )
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: _updating
          ? null
          : () {
              _handleCancel();
            },
      icon: Icon(
        Icons.close,
        color: currScheme.error,
      ),
      label: Text(
        "Remove",
        style: TextStyle(
          color: currScheme.error,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: currScheme.error,
        ),
      ),
    );
  }
}
