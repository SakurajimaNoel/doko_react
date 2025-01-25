import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_to_user_relation_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';

class MessageArchiveProfilePage extends StatelessWidget {
  const MessageArchiveProfilePage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Constants.padding),
        child: Column(
          spacing: Constants.gap * 1.5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserWidget.preview(
              userKey: generateUserNodeKey(username),
            ),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: Constants.fontSize,
                fontWeight: FontWeight.w500,
              ),
              child: UserToUserRelationWidget.info(
                username: username,
              ),
            ),
            Container(
              height: Constants.height * 20,
              padding: EdgeInsets.all(Constants.padding),
              decoration: BoxDecoration(
                color: currTheme.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.radius)),
              ),
              child: Heading(
                "All the media items will appear here.",
                size: Constants.heading2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
