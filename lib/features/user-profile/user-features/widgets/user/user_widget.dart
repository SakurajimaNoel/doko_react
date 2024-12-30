import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
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
        textOnly = false;

  const UserWidget.avtar({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = true,
        textOnly = false;

  const UserWidget.info({
    super.key,
    required this.userKey,
  })  : small = false,
        profileOnly = false,
        textOnly = true;

  const UserWidget.small({
    super.key,
    required this.userKey,
  })  : small = true,
        profileOnly = false,
        textOnly = false;

  const UserWidget.avtarSmall({
    super.key,
    required this.userKey,
  })  : small = true,
        profileOnly = true,
        textOnly = false;

  const UserWidget.infoSmall({
    super.key,
    required this.userKey,
  })  : small = true,
        profileOnly = false,
        textOnly = true;

  final String userKey;
  final bool small;
  final bool profileOnly;
  final bool textOnly;

  @override
  Widget build(BuildContext context) {
    final currentUserKey = generateUserNodeKey(
        (context.read<UserBloc>().state as UserCompleteState).username);

    double gapScale = small ? 0.75 : 1;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionUpdateProfile &&
                userKey == currentUserKey) ||
            (state is UserActionUserRefreshState &&
                generateUserNodeKey(state.username) == userKey);
      },
      builder: (context, state) {
        final UserGraph graph = UserGraph();
        final UserEntity user = graph.getValueByKey(userKey)! as UserEntity;

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
      },
    );
  }

  Widget userInfo(UserEntity user) {
    double usernameScale = small ? 0.9 : 1;
    double nameScale = small ? 1.1 : 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: TextStyle(
            fontSize: Constants.smallFontSize * nameScale,
          ),
        ),
        Text(
          "@${user.username}",
          style: TextStyle(
            fontSize: Constants.smallFontSize * usernameScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget userAvtar(StorageResource profilePicture) {
    double imageDiameter = 40;
    double avtarRadius = small ? 17.5 : 20;

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
}
