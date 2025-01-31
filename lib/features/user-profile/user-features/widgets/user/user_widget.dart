import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
import 'package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserWidget extends StatelessWidget {
  const UserWidget({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = false,
        textOnly = false,
        preview = false,
        large = false,
        share = false;

  const UserWidget.avtar({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = true,
        textOnly = false,
        preview = false,
        large = false,
        share = false;

  const UserWidget.info({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = false,
        textOnly = true,
        preview = false,
        large = false,
        share = false;

  const UserWidget.small({
    super.key,
    required this.userKey,
  })  : small = true,
        profileOnly = false,
        textOnly = false,
        preview = false,
        large = false,
        share = false;

  const UserWidget.avtarSmall({
    super.key,
    required this.userKey,
  })  : small = true,
        profileOnly = true,
        textOnly = false,
        preview = false,
        large = false,
        share = false;

  const UserWidget.infoSmall({
    super.key,
    required this.userKey,
  })  : small = true,
        profileOnly = false,
        textOnly = true,
        preview = false,
        large = false,
        share = false;

  const UserWidget.preview({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = false,
        textOnly = false,
        preview = true,
        large = false,
        share = false;

  const UserWidget.avtarLarge({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = true,
        textOnly = false,
        preview = false,
        large = true,
        share = false;

  const UserWidget.infoShare({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = false,
        textOnly = true,
        preview = false,
        large = false,
        share = true;

  const UserWidget.infoVertical({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = false,
        textOnly = true,
        preview = false,
        large = false,
        share = false;

  final String userKey;
  final bool small;
  final bool profileOnly;
  final bool textOnly;
  final bool large;
  final bool share;

  // highest priority and used in messages
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final currentUser =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final currentUserKey = generateUserNodeKey(currentUser);

    double gapScale = small ? 0.75 : 1;
    final username = getUsernameFromUserKey(userKey);
    final currTheme = Theme.of(context).colorScheme;

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(userKey)) {
      // send a req to fetch this user
      context
          .read<UserToUserActionBloc>()
          .add(UserToUserActionGetUserByUsernameEvent(
            username: username,
            currentUser: currentUser,
          ));
    }

    return BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserToUserActionUpdateProfileState &&
                userKey == currentUserKey) ||
            (state is UserToUserActionUserRefreshState &&
                state.username == username) ||
            (state is UserToUserActionUserDataFetchedState &&
                state.username == username);
      },
      builder: (context, state) {
        final UserGraph graph = UserGraph();
        bool userDataExists = graph.containsKey(userKey);

        if (userDataExists) {
          final UserEntity user = graph.getValueByKey(userKey)! as UserEntity;

          if (preview) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: currTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Constants.radius),
                    boxShadow: [
                      BoxShadow(
                        color: currTheme.shadow.withValues(
                          alpha: 0.5,
                        ),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      userPreviewAvtar(user.profilePicture, constraints),
                      ProfilePictureFilter.preview(
                        child: userPreviewInfo(user, currTheme, username),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.pushNamed(
                              RouterConstants.userProfile,
                              pathParameters: {
                                "username": user.username,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (profileOnly) {
            return userAvtar(user.profilePicture);
          }

          if (textOnly) {
            return userInfo(user);
          }

          return GestureDetector(
            onTap: () {
              context.pushNamed(
                RouterConstants.userProfile,
                pathParameters: {
                  "username": user.username,
                },
              );
            },
            child: Row(
              spacing: Constants.gap * gapScale,
              children: [
                userAvtar(user.profilePicture),
                userInfo(user),
              ],
            ),
          );
        } else {
          final emptyResource = const StorageResource.empty();

          if (preview) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxWidth,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: currTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Constants.radius),
                    boxShadow: [
                      BoxShadow(
                        color: currTheme.shadow.withValues(
                          alpha: 0.25,
                        ),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      userPreviewAvtar(emptyResource, constraints),
                      ProfilePictureFilter.preview(
                        child: userPreviewInfo(null, currTheme, username),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.pushNamed(
                              RouterConstants.userProfile,
                              pathParameters: {
                                "username": username,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (profileOnly) {
            return userAvtar(emptyResource);
          }

          if (textOnly) {
            return userInfoEmpty(username);
          }

          return GestureDetector(
            onTap: () {
              context.pushNamed(
                RouterConstants.userProfile,
                pathParameters: {
                  "username": username,
                },
              );
            },
            child: Row(
              spacing: Constants.gap * gapScale,
              children: [
                userAvtar(emptyResource),
                userInfoEmpty(username),
              ],
            ),
          );
        }
      },
    );
  }

  Widget userInfo(UserEntity user) {
    double usernameScale = small
        ? 0.9
        : share
            ? 0.75
            : 1;
    double nameScale = small
        ? 1.1
        : share
            ? 1
            : 1.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        bool shrink = width < 100;

        return Column(
          crossAxisAlignment:
              share ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trimText(
                user.name,
                len: share || shrink ? 12 : 50,
              ),
              style: TextStyle(
                fontSize: Constants.smallFontSize * nameScale,
              ),
            ),
            Text(
              trimText(
                "@${user.username}",
                len: share || shrink ? 12 : 50,
              ),
              style: TextStyle(
                fontSize: Constants.smallFontSize * usernameScale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget userInfoEmpty(String username) {
    double usernameScale = small ? 1.1 : 1.2;

    return LayoutBuilder(builder: (context, constraints) {
      bool shrink = constraints.maxWidth < 235;

      return Text(
        trimText("@$username", len: shrink ? 8 : 50),
        style: TextStyle(
          fontSize: Constants.smallFontSize * usernameScale,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  Widget userAvtar(StorageResource profilePicture) {
    double radiusFactor = large
        ? 2
        : small
            ? 1
            : 1.25;
    double avtarRadius = Constants.avtarRadius * radiusFactor;
    double imageDiameter = avtarRadius * 2;

    if (profilePicture.bucketPath.isEmpty) {
      return CircleAvatar(
        radius: avtarRadius,
        child: const Icon(Icons.person),
      );
    }

    return CircleAvatar(
      radius: avtarRadius,
      child: ClipOval(
        child: CachedNetworkImage(
          cacheKey: profilePicture.bucketPath,
          imageUrl: profilePicture.accessURI,
          placeholder: (context, url) => const Center(
            child: SmallLoadingIndicator.small(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.cover,
          width: imageDiameter,
          height: imageDiameter,
          memCacheHeight: Constants.thumbnailCacheHeight,
        ),
      ),
    );
  }

  Widget userPreviewInfo(
      UserEntity? user, ColorScheme currTheme, String username) {
    if (user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Heading.left(
            "@$username",
            color: currTheme.onPrimary,
            size: Constants.heading3,
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading.left(
          user.name,
          color: currTheme.onPrimary,
          size: Constants.heading3,
        ),
        Heading.left(
          "@${user.username}",
          size: Constants.fontSize,
          color: currTheme.onPrimary,
        )
      ],
    );
  }

  Widget userPreviewAvtar(
      StorageResource profilePicture, BoxConstraints constraints) {
    if (profilePicture.bucketPath.isEmpty) {
      return Icon(
        Icons.person,
        size: constraints.maxWidth,
      );
    }

    return CachedNetworkImage(
      cacheKey: profilePicture.bucketPath,
      imageUrl: profilePicture.accessURI,
      placeholder: (context, url) => const Center(
        child: SmallLoadingIndicator.small(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
      memCacheHeight: Constants.profileCacheHeight,
      width: constraints.maxWidth,
    );
  }
}

class UserWidgetNew extends StatelessWidget {
  /// this will create normal user widget which allows users to redirect to user profile
  /// this will contains all the user fields avtar, username and name
  const UserWidgetNew({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  const UserWidgetNew.small({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  const UserWidgetNew.large({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  /// this will only contain user avtar with no option to redirect to user profile
  const UserWidgetNew.avtar({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = false,
        avtar = true,
        info = false,
        preview = false;

  const UserWidgetNew.avtarSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = true,
        info = false,
        preview = false;

  const UserWidgetNew.avtarLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = false,
        avtar = true,
        info = false,
        preview = false;

  /// this will only contain user info with no option to redirect to user profile
  const UserWidgetNew.info({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = true,
        preview = false;

  const UserWidgetNew.infoSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = true,
        preview = false;

  const UserWidgetNew.infoLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = false,
        avtar = false,
        info = true,
        preview = false;

  /// this will only contain user name with no option to redirect to user profile
  const UserWidgetNew.name({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = true,
        large = false,
        name = true,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  const UserWidgetNew.nameSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = true,
        normal = false,
        large = false,
        name = true,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  const UserWidgetNew.nameLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = false,
        large = true,
        name = true,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  /// this will only contain user name with no option to redirect to user profile
  const UserWidgetNew.username({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = true,
        avtar = false,
        info = false,
        preview = false;

  const UserWidgetNew.usernameSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = true,
        avtar = false,
        info = false,
        preview = false;

  const UserWidgetNew.usernameLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = true,
        avtar = false,
        info = false,
        preview = false;

  /// this will show user preview widget
  const UserWidgetNew.preview({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
  })  : small = false,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = true;

  final String userKey;

  // size options
  final bool small;
  final bool normal;
  final bool large;

  // field options
  final bool name;
  final bool username;
  final bool avtar;
  final bool info; // info combines both username and name

  // widget options
  final bool preview;

  // user info display trim
  final int trim;
  final double baseFontSize;

  @override
  Widget build(BuildContext context) {
    final currentUser =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final currentUserKey = generateUserNodeKey(currentUser);

    // username for which this widget will be used
    final profileUsername = getUsernameFromUserKey(userKey);
    final currTheme = Theme.of(context).colorScheme;

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(userKey)) {
      // send a req to fetch this user
      context
          .read<UserToUserActionBloc>()
          .add(UserToUserActionGetUserByUsernameEvent(
            username: profileUsername,
            currentUser: currentUser,
          ));
    }

    return BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserToUserActionUpdateProfileState &&
                userKey == currentUserKey) ||
            (state is UserToUserActionUserRefreshState &&
                state.username == profileUsername) ||
            (state is UserToUserActionUserDataFetchedState &&
                state.username == profileUsername);
      },
      builder: (context, state) {
        bool userDataExists = graph.containsKey(userKey);
        UserEntity? user;
        if (userDataExists) {
          user = graph.getValueByKey(userKey)! as UserEntity;
        }

        // if user preview
        if (preview) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: constraints.maxWidth,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: currTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Constants.radius),
                  boxShadow: [
                    BoxShadow(
                      color: currTheme.shadow.withValues(
                        alpha: 0.25,
                      ),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    userPreviewAvtar(
                      profilePicture: user?.profilePicture,
                      constraints: constraints,
                    ),
                    ProfilePictureFilter.preview(
                      child: userPreviewInfo(
                        user: user,
                        currTheme: currTheme,
                        profileUsername: profileUsername,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.pushNamed(
                            RouterConstants.userProfile,
                            pathParameters: {
                              "username": profileUsername,
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        // if avtar
        if (avtar) {
          return userAvtar(
            profilePicture: user?.profilePicture,
          );
        }

        if (name) {
          return userName(
            profileUsername: profileUsername,
            name: user?.name,
          );
        }

        if (username) {
          return userUsername(
            profileUsername: profileUsername,
          );
        }

        if (info) {
          return userInfo(
            profileUsername: profileUsername,
            user: user,
          );
        }

        return userWidget(
          profileUsername: profileUsername,
          context: context,
          user: user,
        );
      },
    );
  }

  /// user preview widgets
  Widget userPreviewAvtar({
    StorageResource? profilePicture,
    required BoxConstraints constraints,
  }) {
    if (profilePicture == null || profilePicture.bucketPath.isEmpty) {
      return Icon(
        Icons.person,
        size: constraints.maxWidth,
      );
    }

    return CachedNetworkImage(
      cacheKey: profilePicture.bucketPath,
      imageUrl: profilePicture.accessURI,
      placeholder: (context, url) => const Center(
        child: SmallLoadingIndicator.small(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
      memCacheHeight: Constants.profileCacheHeight,
      width: constraints.maxWidth,
    );
  }

  Widget userPreviewInfo({
    UserEntity? user,
    required ColorScheme currTheme,
    required String profileUsername,
  }) {
    if (user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Heading.left(
            "@$username",
            color: currTheme.onPrimary,
            size: Constants.heading4,
          )
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Heading.left(
          user.name,
          color: currTheme.onPrimary,
          size: Constants.heading4,
        ),
        Heading.left(
          "@${user.username}",
          size: Constants.fontSize,
          color: currTheme.onPrimary,
        )
      ],
    );
  }

  /// user avtar widgets
  Widget userAvtar({
    StorageResource? profilePicture,
  }) {
    double radiusScaleFactor = 1.25; // normal
    if (large) radiusScaleFactor = 2;
    if (small) radiusScaleFactor = 1;

    double avtarRadius = Constants.avtarRadius * radiusScaleFactor;
    double avtarDiameter = avtarRadius * 2;

    if (profilePicture == null || profilePicture.bucketPath.isEmpty) {
      return CircleAvatar(
        radius: avtarRadius,
        child: const Icon(Icons.person),
      );
    }

    return CircleAvatar(
      radius: avtarRadius,
      child: ClipOval(
        child: CachedNetworkImage(
          cacheKey: profilePicture.bucketPath,
          imageUrl: profilePicture.accessURI,
          placeholder: (context, url) => const Center(
            child: SmallLoadingIndicator.small(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.cover,
          width: avtarDiameter,
          height: avtarDiameter,
          memCacheHeight: Constants.thumbnailCacheHeight,
        ),
      ),
    );
  }

  /// user details widget
  Widget userName({
    required String profileUsername,
    String? name,
  }) {
    double scaleFactor = 1;
    if (large) scaleFactor = 1.125;
    if (small) scaleFactor = 0.875;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool shrink = constraints.maxWidth < 100;

        return Text(
          trimText(
            name ?? "@$profileUsername",
            len: shrink ? 10 : trim,
          ),
          style: TextStyle(
            fontSize: baseFontSize * scaleFactor,
            fontWeight: name == null ? FontWeight.bold : null,
          ),
        );
      },
    );
  }

  Widget userUsername({
    required String profileUsername,
  }) {
    double scaleFactor = 1;
    if (large) scaleFactor = 1.125;
    if (small) scaleFactor = 0.875;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool shrink = constraints.maxWidth < 100;

        return Text(
          trimText(
            "@$profileUsername",
            len: shrink ? 10 : trim,
          ),
          style: TextStyle(
            fontSize: baseFontSize * scaleFactor,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget userInfo({
    required String profileUsername,
    UserEntity? user,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: Constants.gap * 0.125,
      children: [
        if (user?.name != null)
          userName(
            profileUsername: profileUsername,
            name: user?.name,
          ),
        userUsername(
          profileUsername: profileUsername,
        ),
      ],
    );
  }

  Widget userWidget({
    required String profileUsername,
    UserEntity? user,
    required BuildContext context,
  }) {
    double gapScale = 1;
    if (large) gapScale = 1.125;
    if (small) gapScale = 0.875;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouterConstants.userProfile,
          pathParameters: {
            "username": profileUsername,
          },
        );
      },
      child: Row(
        spacing: Constants.gap * gapScale,
        children: [
          userAvtar(
            profilePicture: user?.profilePicture,
          ),
          userInfo(
            profileUsername: profileUsername,
            user: user,
          ),
        ],
      ),
    );
  }
}
