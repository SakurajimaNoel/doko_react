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
import 'package:doko_react/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  final String username;

  const ProfileWidget({
    super.key,
    required this.username,
  });

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  late final bool self;
  late final String username;
  late final UserProvider userProvider;

  final UserGraphqlService userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  bool loading = true;

  // CompleteUserModel? _user;

  @override
  void initState() {
    super.initState();

    userProvider = context.read<UserProvider>();

    username = widget.username;
    self = userProvider.username == username;
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

  Widget queryException(Refetch? refetch) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        actions: appBarActions(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (refetch != null) {
            await refetch();
          } else {
            showMessage(Constants.errorMessage);
          }
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
              Constants.errorMessage,
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

  Widget userNotFound(Refetch? refetch) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        actions: [
          ...appBarActions(),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const ErrorText(
            "Oops! It looks like there's been a mistake. We couldn't find that user.",
            fontSize: Constants.fontSize,
          ),
          const SizedBox(
            height: Constants.gap,
          ),
          ElevatedButton(
            onPressed: () {
              if (refetch != null) refetch();
            },
            child: const Text("Try again"),
          ),
        ],
      ),
    );
  }

  Widget userProfileAction(CompleteUserModel user) {
    if (self) {
      return FilledButton.tonalIcon(
        onPressed: () async {
          // go to edit page
          Map<String, dynamic> data = {
            "bio": user.bio,
          };
          String? newBio = await context.pushNamed<String>(
            RouterConstants.editProfile,
            extra: data,
          );
          // if (user!.bio != newBio) {
          //   setState(() {
          //     user!.bio = newBio ?? "";
          //   });
          // }
        },
        label: const Text("Edit"),
        icon: const Icon(Icons.edit_note),
      );
    }

    var status = FriendRelation.getFriendRelationStatus(
      user.friendRelationDetail,
      currentUsername: userProvider.username,
    );

    return _UserProfileAction(
      status: status,
      user: user,
    );
  }

  Widget loader() {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
        actions: [
          ...appBarActions(),
        ],
      ),
      body: const Loader(),
    );
  }

  Widget userProfileInfo(CompleteUserModel user) {
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
                  "Posts: ${DisplayText.displayNumericValue(user.postsCount)}",
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
          label: Text(
              "Friends: ${DisplayText.displayNumericValue(user.friendsCount)}"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme currTheme = Theme.of(context).colorScheme;
    final double width = MediaQuery.sizeOf(context).width;
    final double height = width * (1 / Constants.profile);

    return Query(
      options: QueryOptions(
        pollInterval: const Duration(
          minutes: 10,
        ),
        document: gql(UserQueries.getCompleteUser()),
        variables: UserQueries.getCompleteUserVariables(
          username,
          currentUsername: userProvider.username,
        ),
      ),
      builder: (QueryResult result, {Refetch? refetch, FetchMore? fetchMore}) {
        List res = result.data?["users"] ?? [];

        if (result.hasException) {
          return queryException(refetch);
        }

        if (res.isEmpty && result.isLoading) {
          return loader();
        }

        if (res.isEmpty) {
          return userNotFound(refetch);
        }

        final Future<CompleteUserModel> futureUser =
            CompleteUserModel.createModel(map: res[0]);

        return FutureBuilder<CompleteUserModel>(
          future: futureUser,
          builder: (BuildContext context,
              AsyncSnapshot<CompleteUserModel> snapshot) {
            if (snapshot.hasError) {
              return queryException(refetch);
            }

            if (!snapshot.hasData) {
              return loader();
            }

            final user = snapshot.data!;

            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  if (refetch != null) {
                    await refetch();
                  } else {
                    showMessage(Constants.errorMessage);
                  }
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: height,
                      title: Text(user.username),
                      actions: appBarActions(),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            user.profilePicture.isNotEmpty
                                ? CachedNetworkImage(
                                    memCacheHeight:
                                        Constants.profileCacheHeight,
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
                                height: Constants.gap,
                              ),
                            ],
                            userProfileAction(user),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        userProfileInfo(user),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: Constants.gap * 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // var currTheme = Theme.of(context).colorScheme;
    // var _userProvider = context.watch<UserProvider>();
    // var width = MediaQuery.sizeOf(context).width;
    // var height = width * (1 / Constants.profile);

    // var user = _user;

    // if (loading) {
    //   return loader();
    // }

    // if (user == null) {
    //   return queryException(null);
    // }

    // if (self) {
    //   user.profilePicture = userProvider.profilePicture;
    //   user.signedProfilePicture = userProvider.signedProfilePicture;
    //   user.name = userProvider.name;
    // }

    // return Scaffold(
    //   body: RefreshIndicator(
    //     onRefresh: () async {
    //       // await _fetchCompleteUser();
    //     },
    //     child: CustomScrollView(
    //       physics: const AlwaysScrollableScrollPhysics(),
    //       slivers: [
    //         SliverAppBar(
    //           floating: false,
    //           pinned: true,
    //           expandedHeight: height,
    //           title: Text(user.username),
    //           actions: appBarActions(),
    //           flexibleSpace: FlexibleSpaceBar(
    //             background: Stack(
    //               fit: StackFit.expand,
    //               children: [
    //                 user.profilePicture.isNotEmpty
    //                     ? CachedNetworkImage(
    //                         memCacheHeight: Constants.profileCacheHeight,
    //                         cacheKey: user.profilePicture,
    //                         imageUrl: user.signedProfilePicture,
    //                         fit: BoxFit.cover,
    //                         placeholder: (context, url) => const Center(
    //                           child: CircularProgressIndicator(),
    //                         ),
    //                         errorWidget: (context, url, error) =>
    //                             const Icon(Icons.error),
    //                         height: height,
    //                       )
    //                     : Container(
    //                         color: currTheme.onSecondary,
    //                         child: Icon(
    //                           Icons.person,
    //                           size: height,
    //                         ),
    //                       ),
    //                 Container(
    //                   padding: const EdgeInsets.only(
    //                     bottom: Constants.padding,
    //                     left: Constants.padding,
    //                   ),
    //                   alignment: Alignment.bottomLeft,
    //                   decoration: BoxDecoration(
    //                     gradient: LinearGradient(
    //                       begin: Alignment.topCenter,
    //                       end: Alignment.bottomCenter,
    //                       colors: [
    //                         currTheme.surface.withOpacity(0.5),
    //                         currTheme.surface.withOpacity(0.25),
    //                         currTheme.surface.withOpacity(0.25),
    //                         currTheme.surface.withOpacity(0.5),
    //                       ],
    //                     ),
    //                   ),
    //                   child: Text(
    //                     user.name,
    //                     style: TextStyle(
    //                       color: currTheme.onSurface,
    //                       fontSize: Constants.heading2,
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //         SliverToBoxAdapter(
    //           child: Padding(
    //             padding: const EdgeInsets.all(Constants.padding),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 if (user.bio.isNotEmpty) ...[
    //                   Text(user.bio),
    //                   const SizedBox(
    //                     height: 16,
    //                   ),
    //                 ],
    //                 _userProfileAction(),
    //               ],
    //             ),
    //           ),
    //         ),
    //         SliverPersistentHeader(
    //           pinned: true,
    //           delegate: _SliverAppBarDelegate(
    //             _userProfileInfo(),
    //           ),
    //         ),
    //         const SliverToBoxAdapter(
    //           child: SizedBox(
    //             height: Constants.gap * 2,
    //           ),
    //         ),
    //         PostContainerProfileWidget(
    //           postInfo: user.postsInfo,
    //           user: user,
    //           key: ObjectKey(user.postsInfo),
    //         ),
    //         const SliverToBoxAdapter(
    //           child: SizedBox(
    //             height: Constants.gap * 2,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
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

  late final UserProvider userProvider;

  final UserGraphqlService userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    _status = widget.status;
    _user = widget.user;

    userProvider = context.read<UserProvider>();
  }

  Future<void> _handleAdd() async {
    setState(() {
      _status = FriendRelationStatus.outgoingReq;
      _updating = true;
    });

    String requestedByUsername = userProvider.username;
    String requestedToUsername = _user.username;

    var addResponse = await userGraphqlService.userSendFriendRequest(
      requestedByUsername: requestedByUsername,
      requestedToUsername: requestedToUsername,
    );
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
      requestedByUsername: requestedByUsername,
      status: FriendStatus.pending,
      addedOn: DateTime.timestamp(),
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
        errorMessage = Constants.errorMessage;
    }

    setState(() {
      _status = FriendRelationStatus.unrelated;
      _updating = true;
    });

    String requestedByUsername =
        _user.friendRelationDetail!.requestedByUsername;
    String requestedToUsername = requestedByUsername == userProvider.username
        ? _user.username
        : userProvider.username;

    var cancelResponse = await userGraphqlService.userRemoveFriendRelation(
      requestedByUsername: requestedByUsername,
      requestedToUsername: requestedToUsername,
    );
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

    String requestedByUsername =
        _user.friendRelationDetail!.requestedByUsername;
    String requestedToUsername = requestedByUsername == userProvider.username
        ? _user.username
        : userProvider.username;

    var acceptResponse = await userGraphqlService.userAcceptFriendRequest(
      requestedByUsername: requestedByUsername,
      requestedToUsername: requestedToUsername,
    );

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
      duration: Constants.snackBarDuration,
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
