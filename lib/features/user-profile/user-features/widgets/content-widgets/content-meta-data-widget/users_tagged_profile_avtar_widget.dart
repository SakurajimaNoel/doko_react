import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';

class UsersTaggedAvtarWidget extends StatefulWidget {
  const UsersTaggedAvtarWidget({
    super.key,
    required this.usersTagged,
    required this.nodeCreatedBy,
    this.onTap,
  });

  final List<UsersTagged> usersTagged;
  final String nodeCreatedBy; // user key
  final VoidCallback? onTap;

  @override
  State<UsersTaggedAvtarWidget> createState() => _UsersTaggedAvtarWidgetState();
}

class _UsersTaggedAvtarWidgetState extends State<UsersTaggedAvtarWidget> {
  late final usersTagged = widget.usersTagged;
  late final nodeCreatedBy = widget.nodeCreatedBy;

  late UsersTagged currentDisplay;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    currentDisplay = usersTagged.first;
    if (usersTagged.length > 1) updateUsersTagged();
  }

  void updateUsersTagged() {
    setState(() {
      currentDisplay = usersTagged[currentIndex];
      currentIndex = (currentIndex + 1) % usersTagged.length;
    });

    Timer(
      const Duration(
        seconds: 8,
      ),
      updateUsersTagged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: SizedBox(
        height: Constants.avtarRadius * 3,
        width: Constants.avtarRadius * 3,
        child: Stack(
          children: [
            Positioned(
              child: CircleAvatar(
                radius: Constants.avtarRadius,
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 2000,
                  ),
                  key: ObjectKey(currentDisplay),
                  child: currentDisplay.profilePicture.bucketPath.isEmpty
                      ? const Icon(Icons.person)
                      : ClipOval(
                          key: ObjectKey(currentDisplay),
                          child: CachedNetworkImage(
                            key: ObjectKey(currentDisplay),
                            cacheKey: currentDisplay.profilePicture.bucketPath,
                            imageUrl: currentDisplay.profilePicture.accessURI,
                            placeholder: (context, url) => const Center(
                              child: LoadingWidget.small(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                            memCacheHeight: Constants.thumbnailCacheHeight,
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              top: Constants.avtarRadius,
              left: Constants.avtarRadius,
              child: UserWidget.avtarSmall(
                userKey: nodeCreatedBy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
