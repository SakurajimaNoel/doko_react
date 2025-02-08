import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:flutter/material.dart';

class NodeCommentProvider extends ChangeNotifier {
  NodeCommentProvider({
    required this.focusNode,
    required this.rootNodeId,
    required this.rootNodeCreatedBy,
    required this.targetByUser,
    // required this.commentTargetId,
    required this.rootNodeType,
    this.replyOn,
  });

  final FocusNode focusNode;

  String? replyOn;

  // new node will have commentOn relationship with this node
  // String commentTargetId;

  // username of user whose comment reply is clicked
  String targetByUser;

  // root node details like post, comment,
  final String rootNodeId;
  final String rootNodeCreatedBy;

  // when navigating to comment page
  final DokiNodeType rootNodeType;

  // new comment or reply will be added to commentTargetId
  void updateCommentTarget(String targetUser, String targetId) {
    targetByUser = targetUser;
    replyOn = targetId;

    notifyListeners();
  }

  void resetCommentTarget() {
    replyOn = null;
    targetByUser = rootNodeCreatedBy;

    notifyListeners();
  }

  // to render info box above input
  bool get isReply => replyOn != null && replyOn!.isNotEmpty;
}
