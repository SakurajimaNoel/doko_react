import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MarkdownDisplayWidget extends StatelessWidget {
  const MarkdownDisplayWidget({
    super.key,
    required this.data,
  });

  final String data;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return MarkdownBody(
      data: data,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        a: TextStyle(
          color: currTheme.primary,
          fontWeight: FontWeight.w500,
        ),
        blockquoteDecoration: BoxDecoration(
          color: currTheme.secondaryContainer,
          borderRadius: BorderRadius.circular(Constants.radius),
        ),
      ),
      onTapLink: (String text, String? url, String title) async {
        if (url != null) {
          if (url.startsWith("doki@")) {
            // doki nodes
            List<String> urlList = url.split(":");

            if (urlList.length == 2) {
              String nodeIdentifier = urlList.last;
              String nodeTypeString = urlList.first.substring(5);

              DokiNodeType nodeType = DokiNodeType.fromName(nodeTypeString);

              if (nodeType == DokiNodeType.user && nodeTypeString == "user") {
                context.pushNamed(
                  RouterConstants.userProfile,
                  pathParameters: {
                    "username": nodeIdentifier,
                  },
                );
              }

              if (nodeType == DokiNodeType.post) {
                context.pushNamed(
                  RouterConstants.userPost,
                  pathParameters: {
                    "postId": nodeIdentifier,
                  },
                );
              }
              if (nodeType == DokiNodeType.poll) {
                context.pushNamed(
                  RouterConstants.userPoll,
                  pathParameters: {
                    "pollId": nodeIdentifier,
                  },
                );
              }
              if (nodeType == DokiNodeType.discussion) {
                context.pushNamed(
                  RouterConstants.userDiscussion,
                  pathParameters: {
                    "discussionId": nodeIdentifier,
                  },
                );
              }
            }
            return;
          }

          Uri? uri = Uri.tryParse(url);
          String urlString = '';
          if (uri != null) {
            if (uri.scheme.isEmpty) urlString = 'https://';
            urlString += uri.toString();

            launchUrlString(urlString);
          }
        }
      },
    );
  }
}
