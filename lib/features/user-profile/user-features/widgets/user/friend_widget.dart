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
  });

  final String userKey;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.pushNamed(
          RouterConstants.userProfile,
          pathParameters: {
            "username": getUsernameFromUserKey(userKey),
          },
        );
      },
      minVerticalPadding: Constants.padding * 0.75,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      leading: UserWidget.avtar(
        userKey: userKey,
      ),
      trailing: UserToUserRelationWidget(
        username: getUsernameFromUserKey(userKey),
        key: ValueKey("${userKey}_relation"),
      ),
      title: UserWidget.info(
        userKey: userKey,
      ),
    );
  }
}
