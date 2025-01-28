import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
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
      context.read<UserActionBloc>().add(UserActionGetUserByUsernameEvent(
            username: username,
            currentUser: currentUser,
          ));
    }

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionUpdateProfile &&
                userKey == currentUserKey) ||
            (state is UserActionUserRefreshState &&
                state.username == username) ||
            (state is UserActionUserDataFetchedState &&
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
                        offset: Offset(0, 2),
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
          final emptyResource = StorageResource.empty();

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
                        offset: Offset(0, 2),
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
                fontWeight: FontWeight.w600,
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
          fontWeight: FontWeight.w600,
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
        child: Icon(Icons.person),
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
      UserEntity? user, ColorScheme currTheme, String usename) {
    if (user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Heading.left(
            "@$usename",
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
