import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/loader/loader.dart';
import 'package:doko_react/features/User/data/graphql_queries/friend_relation.dart';
import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
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
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  late final bool _self;
  late final String _userId;
  late final UserProvider _userProvider;

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

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
          auth.signOutUser();
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
                auth.signOutUser();
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

  Widget _userProfileInfo() {
    var currTheme = Theme.of(context).colorScheme;

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
                  "Posts: ${DisplayText.displayNumericValue(_user!.postsCount)}",
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
                "userId": _userId,
              },
              extra: {
                "name": _user!.name,
              },
            );
          },
          icon: const Icon(Icons.group),
          label: Text(
              "Friends: ${DisplayText.displayNumericValue(_user!.friendsCount)}"),
        ),
      ],
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

    var caption = user.postsInfo.posts.isNotEmpty
        ? user.postsInfo.posts[0].createdOn.toString()
        : "user";

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchCompleteUser();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
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
                _userProfileInfo(),
              ),
            ),
            PostContainerProfileWidget(
              postInfo: user.postsInfo,
              user: user,
              key: ValueKey(
                "${user.username} $caption posts",
              ),
            ),
          ],
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

  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );
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
