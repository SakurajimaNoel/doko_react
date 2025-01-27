import 'package:doko_react/core/utils/text-controller/mention_text_controller.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/entity/comment/comment_media.dart';
import 'package:flutter/material.dart';

class CommentInputProvider extends ChangeNotifier {
  CommentInputProvider({
    required this.commentController,
  }) : showMore = false;

  CommentMedia? media;
  final MentionTextController commentController;
  bool showMore;

  void addMedia(CommentMedia media) {
    this.media = media;

    notifyListeners();
  }

  void removeMedia() {
    media = null;

    notifyListeners();
  }

  void updateShowMore(bool showMore) {
    this.showMore = showMore;

    notifyListeners();
  }

  void reset() {
    media = null;
    commentController.clear();

    notifyListeners();
  }
}
