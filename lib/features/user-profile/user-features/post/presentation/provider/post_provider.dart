import 'package:flutter/cupertino.dart';

class PostCommentProvider extends ChangeNotifier {
  PostCommentProvider({
    required this.focusNode,
    required this.postId,
    required this.postCreatedBy,
    required this.targetByUser,
    required this.commentTargetId,
  });

  final FocusNode focusNode;
  String commentTargetId;
  String targetByUser;
  final String postId;
  final String postCreatedBy;

  // new comment or reply will be added to commentTargetId
  void updateCommentTarget(String targetId, String targetUser) {
    commentTargetId = targetId;
    targetByUser = targetUser;

    notifyListeners();
  }

  void resetCommentTarget() {
    commentTargetId = postId;
    targetByUser = postCreatedBy;

    notifyListeners();
  }

  // to render info box above input
  bool get isReply => commentTargetId != postId;
}
