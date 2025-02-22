import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class PollEntity implements NodeWithCommentEntity {
  PollEntity({
    required this.id,
    required this.createdOn,
    required this.createdBy,
    required this.likesCount,
    required this.commentsCount,
    required this.comments,
    required this.userLike,
    required this.usersTagged,
    required this.question,
  });

  final String id;
  final DateTime createdOn;
  final String createdBy;
  final List<String> usersTagged;

  final String question;

  int likesCount;
  @override
  int commentsCount;
  bool userLike;
  @override
  Nodes comments;

  void updateUserLikeStatus(bool userLike) {
    this.userLike = userLike;
  }

  void updateLikeCount(int likesCount) {
    this.likesCount = likesCount;
  }

  @override
  void updateCommentsCount(int newCommentsCount) {
    commentsCount = newCommentsCount;
  }

  static Future<PollEntity> createEntity({required Map map}) async {
    final String createdByUsername = map["createdBy"]["username"];
    String key = generateUserNodeKey(createdByUsername);

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(key)) {
      UserEntity user = await UserEntity.createEntity(map: map["createdBy"]);
      String key = generateUserNodeKey(user.username);

      graph.addEntity(key, user);
    }

    bool userLike = (map["likedBy"] as List).length == 1;

    List<String> usersTagged = [];
    if (map["usersTagged"] != null) {
      for (var el in (map["usersTagged"] as List)) {
        usersTagged.add(el["username"]);
      }
    }

    return PollEntity(
      id: map["id"],
      createdOn: DateTime.parse(map["createdOn"]),
      createdBy: key,
      comments: Nodes.empty(),
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
      userLike: userLike,
      usersTagged: usersTagged,
      question: map["question"],
    );
  }
}
