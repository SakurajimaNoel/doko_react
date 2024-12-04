import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class User extends StatelessWidget {
  const User({
    super.key,
    required this.userKey,
  });

  final String userKey;

  @override
  Widget build(BuildContext context) {
    final currentUserKey = generateUserNodeKey(
        (context.read<UserBloc>().state as UserCompleteState).username);

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionUpdateProfile && userKey == currentUserKey);
      },
      builder: (context, state) {
        final UserGraph graph = UserGraph();
        final UserEntity user = graph.getValueByKey(userKey)! as UserEntity;

        return GestureDetector(
          onTap: () {
            // todo: redirect to user profile
          },
          child: Row(
            children: [
              userAvtar(user.profilePicture),
              const SizedBox(
                width: Constants.gap,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name),
                  Text(
                    "@${user.username}",
                    style: const TextStyle(
                      fontSize: Constants.smallFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget userAvtar(StorageResource profilePicture) {
    if (profilePicture.bucketPath.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.person),
      );
    }

    return CircleAvatar(
      child: ClipOval(
        child: CachedNetworkImage(
          cacheKey: profilePicture.bucketPath,
          imageUrl: profilePicture.accessURI,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          memCacheHeight: Constants.thumbnailCacheHeight,
        ),
      ),
    );
  }
}
