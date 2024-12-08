import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_to_user_relation_widget.dart';
import 'package:flutter/material.dart';

class FriendWidget extends StatelessWidget {
  const FriendWidget({
    super.key,
    required this.userKey,
  });

  final String userKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        User(
          userKey: userKey,
          key: ValueKey("${userKey}_user"),
        ),
        UserToUserRelationWidget(
          username: generateUsernameFromKey(userKey),
          key: ValueKey("${userKey}_relation"),
        ),
      ],
    );
  }
}
