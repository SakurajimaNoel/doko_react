import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:flutter/material.dart';

class NodeCommentProvider extends ChangeNotifier {
  NodeCommentProvider({
    required this.focusNode,
    required this.rootNodeId,
    required this.rootNodeCreatedBy,
    required this.targetByUser,
    required this.commentTargetId,
    required this.rootNodeType,
  });

  final FocusNode focusNode;
  String commentTargetId;
  String targetByUser;
  final String rootNodeId;
  final String rootNodeCreatedBy;
  // when navigating to comment page
  final DokiNodeType rootNodeType;

  // new comment or reply will be added to commentTargetId
  void updateCommentTarget(String targetId, String targetUser) {
    commentTargetId = targetId;
    targetByUser = targetUser;

    notifyListeners();
  }

  void resetCommentTarget() {
    commentTargetId = rootNodeId;
    targetByUser = rootNodeCreatedBy;

    notifyListeners();
  }

  // to render info box above input
  bool get isReply => commentTargetId != rootNodeId;
}
