import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
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
  /// this will create normal user widget which allows users to redirect to user profile
  /// this will contains all the user fields avtar, username and name
  const UserWidget({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = false,
        bold = false;

  const UserWidget.small({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = false,
        bold = false;

  const UserWidget.large({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = false,
        bold = false;

  /// this will only contain user avtar with no option to redirect to user profile
  const UserWidget.avtar({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = false,
        avtar = true,
        info = false,
        preview = false,
        bold = false;

  const UserWidget.avtarSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = true,
        info = false,
        preview = false,
        bold = false;

  const UserWidget.avtarLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = false,
        avtar = true,
        info = false,
        preview = false,
        bold = false;

  /// this will only contain user info with no option to redirect to user profile
  const UserWidget.info({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = true,
        preview = false,
        bold = false;

  const UserWidget.infoSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = true,
        preview = false,
        bold = false;

  const UserWidget.infoLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = false,
        avtar = false,
        info = true,
        preview = false,
        bold = false;

  /// this will only contain user name with no option to redirect to user profile
  const UserWidget.name({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.bold = false,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = true,
        large = false,
        name = true,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  const UserWidget.nameSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
    this.bold = false,
  })  : small = true,
        normal = false,
        large = false,
        name = true,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  const UserWidget.nameLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
    this.bold = false,
  })  : small = false,
        normal = false,
        large = true,
        name = true,
        username = false,
        avtar = false,
        info = false,
        preview = false;

  /// this will only contain user name with no option to redirect to user profile
  const UserWidget.username({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = true,
        large = false,
        name = false,
        username = true,
        avtar = false,
        info = false,
        preview = false,
        bold = false;

  const UserWidget.usernameSmall({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = true,
        normal = false,
        large = false,
        name = false,
        username = true,
        avtar = false,
        info = false,
        preview = false,
        bold = false;

  const UserWidget.usernameLarge({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = false,
        large = true,
        name = false,
        username = true,
        avtar = false,
        info = false,
        preview = false,
        bold = false;

  /// this will show user preview widget
  const UserWidget.preview({
    super.key,
    required this.userKey,
    this.trim = 30,
    this.baseFontSize = Constants.fontSize,
    this.redirect = false,
  })  : small = false,
        normal = false,
        large = false,
        name = false,
        username = false,
        avtar = false,
        info = false,
        preview = true,
        bold = false;

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
  final bool bold; // only used with name options

  // to allow redirect
  final bool redirect;

  @override
  Widget build(BuildContext context) {
    final currentUser =
        (context.read<UserBloc>().state as UserCompleteState).username;

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

    bool redirect = this.redirect;
    if (redirect) {
      // check is user profile page and skip redirect
      final String routeName = GoRouter.of(context).currentRouteName ?? "";
      final Map<String, String> pathParams =
          GoRouter.of(context).currentRoutePathParameters;
      if ((routeName == RouterConstants.userProfile &&
              pathParams["username"] == getUsernameFromUserKey(userKey) ||
          (routeName == RouterConstants.profile &&
              getUsernameFromUserKey(userKey) == currentUser))) {
        redirect = false;
      }
    }

    return BlocBuilder<UserToUserActionBloc, UserToUserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserToUserActionUpdateProfileState &&
                state.username == profileUsername) ||
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
          return InkWell(
            onTap: redirect
                ? () {
                    context.pushNamed(
                      RouterConstants.userProfile,
                      pathParameters: {
                        "username": profileUsername,
                      },
                    );
                  }
                : null,
            child: userAvtar(
              profilePicture: user?.profilePicture,
            ),
          );
        }

        if (name) {
          return InkWell(
            onTap: redirect
                ? () {
                    context.pushNamed(
                      RouterConstants.userProfile,
                      pathParameters: {
                        "username": profileUsername,
                      },
                    );
                  }
                : null,
            child: userName(
              profileUsername: profileUsername,
              name: user?.name,
            ),
          );
        }

        if (username) {
          return InkWell(
            onTap: redirect
                ? () {
                    context.pushNamed(
                      RouterConstants.userProfile,
                      pathParameters: {
                        "username": profileUsername,
                      },
                    );
                  }
                : null,
            child: userUsername(
              profileUsername: profileUsername,
            ),
          );
        }

        if (info) {
          return InkWell(
            onTap: redirect
                ? () {
                    context.pushNamed(
                      RouterConstants.userProfile,
                      pathParameters: {
                        "username": profileUsername,
                      },
                    );
                  }
                : null,
            child: userInfo(
              profileUsername: profileUsername,
              user: user,
            ),
          );
        }

        return InkWell(
          onTap: () {
            if (redirect) {
              context.pushNamed(
                RouterConstants.userProfile,
                pathParameters: {
                  "username": profileUsername,
                },
              );
            }
          },
          child: userWidget(
            profileUsername: profileUsername,
            context: context,
            user: user,
          ),
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

    return Text(
      trimText(
        name ?? "@$profileUsername",
        len: trim,
      ),
      style: TextStyle(
        fontSize: baseFontSize * scaleFactor,
        fontWeight: name == null || bold ? FontWeight.bold : null,
      ),
    );
  }

  Widget userUsername({
    required String profileUsername,
  }) {
    double scaleFactor = 1;
    if (large) scaleFactor = 1.125;
    if (small) scaleFactor = 0.875;

    return Text(
      "@${trimText(
        profileUsername,
        len: trim,
      )}",
      style: TextStyle(
        fontSize: baseFontSize * scaleFactor,
        fontWeight: FontWeight.bold,
      ),
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
    if (small) gapScale = 0.75;

    return Row(
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
    );
  }
}
