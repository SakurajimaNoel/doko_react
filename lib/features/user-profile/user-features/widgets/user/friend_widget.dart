import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_to_user_relation_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendWidget extends StatelessWidget {
  const FriendWidget({
    super.key,
    required this.userKey,
  }) : showMessageOption = false;

  const FriendWidget.message({
    super.key,
    required this.userKey,
  }) : showMessageOption = true;

  final String userKey;

  /// used with inbox search widgets
  final bool showMessageOption;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool shrink = constraints.maxWidth < Constants.shrinkWidth;

        return ListTile(
          onTap: () {
            if (showMessageOption) {
              context.pushNamed(
                RouterConstants.messageArchive,
                pathParameters: {
                  "username": getUsernameFromUserKey(userKey),
                },
              );
              return;
            }

            context.pushNamed(
              RouterConstants.userProfile,
              pathParameters: {
                "username": getUsernameFromUserKey(userKey),
              },
            );
          },
          minVerticalPadding: Constants.padding * 0.25,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          leading: shrink
              ? UserWidget.avtarSmall(
                  key: ValueKey("$userKey-small-avtar"),
                  userKey: userKey,
                )
              : UserWidget.avtar(
                  userKey: userKey,
                ),
          trailing: showMessageOption
              ? null
              : shrink
                  ? null
                  : UserToUserRelationWidget(
                      username: getUsernameFromUserKey(userKey),
                      key: ValueKey("${userKey}_relation"),
                    ),
          title: UserWidget.name(
            userKey: userKey,
          ),
          subtitle: UserWidget.username(
            userKey: userKey,
          ),
        );
      },
    );
  }
}
