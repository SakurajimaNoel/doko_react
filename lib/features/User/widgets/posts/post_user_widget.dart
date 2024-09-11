import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/data/storage.dart';
import '../../../../core/helpers/constants.dart';
import '../../../../core/helpers/enum.dart';
import '../../data/model/user_model.dart';

class PostUserWidget extends StatelessWidget {
  final UserModel user;
  final String? profileImg;

  const PostUserWidget({
    super.key,
    required this.user,
    this.profileImg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        profileImg != null && profileImg!.isNotEmpty
            ? _UserProfileImageProvided(
                userProfileImg: profileImg!,
                profilePath: user.profilePicture,
              )
            : _UserProfileImage(
                profilePath: user.profilePicture,
              ),
        const SizedBox(
          width: Constants.gap * 0.5,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name),
            Text(
              // TODO: make it clickable
              "@${user.username}",
              style: const TextStyle(
                fontSize: Constants.smallFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }
}

// user profile picture when url provided
class _UserProfileImageProvided extends StatelessWidget {
  final String userProfileImg;
  final String profilePath;

  const _UserProfileImageProvided({
    super.key,
    required this.userProfileImg,
    required this.profilePath,
  });

  @override
  Widget build(BuildContext context) {
    return profilePath.isEmpty
        ? const CircleAvatar(
            child: Icon(Icons.person),
          )
        : CircleAvatar(
            child: ClipOval(
              child: CachedNetworkImage(
                cacheKey: userProfileImg,
                imageUrl: userProfileImg,
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

// user profile picture widget
class _UserProfileImage extends StatefulWidget {
  final String profilePath;

  const _UserProfileImage({
    super.key,
    required this.profilePath,
  });

  @override
  State<_UserProfileImage> createState() => _UserProfileImageState();
}

class _UserProfileImageState extends State<_UserProfileImage> {
  String _userProfileImg = "";
  late final String _profilePath;

  @override
  void initState() {
    super.initState();
    _profilePath = widget.profilePath;
    _getProfile(_profilePath);
  }

  Future<void> _getProfile(String path) async {
    if (path.isEmpty) {
      return;
    }

    var result = await StorageActions.getDownloadUrl(path);

    if (result.status == ResponseStatus.success) {
      if (mounted) {
        setState(() {
          _userProfileImg = result.value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _userProfileImg.isEmpty
        ? const CircleAvatar(
            child: Icon(Icons.person),
          )
        : CircleAvatar(
            child: ClipOval(
              child: CachedNetworkImage(
                cacheKey: _profilePath,
                imageUrl: _userProfileImg,
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
