import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({
    super.key,
    required this.commentId,
    required this.rootNodeId,
    required this.rootNodeType,
  });

  final String commentId;

  /// root node and root node type help to identify where to redirect
  /// discussion or post
  final String rootNodeId;
  final DokiNodeType rootNodeType;

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late final DokiNodeType rootNodeType = widget.rootNodeType;
  late final String rootNodeId = widget.rootNodeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comment"),
        actions: [
          TextButton(
            onPressed: () {
              // redirect to correct page
              if (rootNodeType == DokiNodeType.post) {
                // go to post page
                context.pushReplacementNamed(
                  RouterConstants.userPost,
                  pathParameters: {
                    "postId": rootNodeId,
                  },
                );
              }
            },
            child: Text("Go to ${widget.rootNodeType.name} "),
          ),
          const SizedBox(
            width: Constants.gap,
          ),
        ],
      ),
    );
  }
}
