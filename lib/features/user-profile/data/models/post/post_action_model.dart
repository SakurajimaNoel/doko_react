class PostActionModel {
  const PostActionModel({
    required this.userLike,
    required this.likesCount,
    required this.commentsCount,
  });

  final bool userLike;
  final int likesCount;
  final int commentsCount;

  static PostActionModel createModel(Map map) {
    bool userLike = (map["likedBy"] as List).length == 1;

    return PostActionModel(
      userLike: userLike,
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
    );
  }
}
