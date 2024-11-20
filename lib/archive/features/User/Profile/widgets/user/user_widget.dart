import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/archive/core/configs/router/router_constants.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/features/User/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserWidget extends StatelessWidget {
  final UserModel user;

  const UserWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          _UserProfileImage(
            user: user,
          ),
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
  }
}

// user profile picture
class _UserProfileImage extends StatelessWidget {
  final UserModel user;

  const _UserProfileImage({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return user.profilePicture.isEmpty
        ? const CircleAvatar(
            child: Icon(Icons.person),
          )
        : CircleAvatar(
            child: ClipOval(
              child: CachedNetworkImage(
                cacheKey: user.profilePicture,
                imageUrl: user.signedProfilePicture,
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
