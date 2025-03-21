import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class NodeCommentProvider extends ChangeNotifier {
  NodeCommentProvider({
    required this.focusNode,
    required this.rootNodeId,
    required this.rootNodeCreatedBy,
    required this.targetByUser,
    required this.commentTargetId,
    required this.commentTargetNodeType,
    required this.commentTargetNodeBy,
    required this.rootNodeType,
    this.replyOn,
    this.controller,
  });

  final FocusNode focusNode;

  final SliverObserverController? controller;

  /// node id of comment whose reply it will be
  /// this can be null
  String? replyOn;

  /// new node will have commentOn relationship with this node
  /// in post page this will be post, in comment page it will be comment id of that page
  final String commentTargetId;
  final DokiNodeType commentTargetNodeType;

  /// used to send remote events
  final String commentTargetNodeBy;

  /// username of user whose comment reply is clicked
  /// used for display purposes
  String targetByUser;

  /// root node details like post, or discussion but not comment
  /// will be used with comment media bucket storage path
  final String rootNodeId;
  final String rootNodeCreatedBy;

  /// used when navigating to comment page and when creating new comment node
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
