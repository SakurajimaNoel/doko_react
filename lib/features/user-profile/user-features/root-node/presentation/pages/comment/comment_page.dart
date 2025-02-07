import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
