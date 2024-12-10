class CommentActionModel {
  const CommentActionModel({
    required this.userLike,
    required this.likesCount,
    required this.commentsCount,
  });

  final bool userLike;
  final int likesCount;
  final int commentsCount;

  static CommentActionModel createModel(Map map) {
    bool userLike = (map["likedBy"] as List).length == 1;

    return CommentActionModel(
      userLike: userLike,
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
    );
  }
}
