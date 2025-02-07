import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:flutter/material.dart';

class RootNodeCommentProvider extends ChangeNotifier {
  RootNodeCommentProvider({
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
  final NodeType rootNodeType;

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
