/// this handles user like action on nodes
class UserActionModel {
  const UserActionModel({
    required this.userLike,
    required this.likesCount,
    required this.commentsCount,
  });

  final bool userLike;
  final int likesCount;

  final int commentsCount;

  static UserActionModel createModel(Map map) {
    bool userLike = (map["likedBy"] as List).length == 1;

    return UserActionModel(
      userLike: userLike,
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
    );
  }
}
