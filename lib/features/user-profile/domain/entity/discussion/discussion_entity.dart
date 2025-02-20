import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/media/media_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class DiscussionEntity implements NodeWithMediaItems {
  DiscussionEntity({
    required this.id,
    required this.title,
    required this.createdOn,
    required this.createdBy,
    required this.media,
    required this.text,
    required this.likesCount,
    required this.commentsCount,
    required this.comments,
    required this.userLike,
    required this.usersTagged,
  });

  final String id;
  final String title;
  final DateTime createdOn;
  final String createdBy;
  final List<MediaEntity> media;
  final String text;
  final List<String> usersTagged;

  int likesCount;
  @override
  int commentsCount;
  bool userLike;

  @override
  Nodes comments;

  @override
  int currDisplay = 0;

  @override
  void updateDisplayItem(int item) {
    currDisplay = item;
  }

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

  static Future<DiscussionEntity> createEntity({required Map map}) async {
    final String createdByUsername = map["createdBy"]["username"];
    String key = generateUserNodeKey(createdByUsername);

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(key)) {
      UserEntity user = await UserEntity.createEntity(map: map["createdBy"]);
      String key = generateUserNodeKey(user.username);

      graph.addEntity(key, user);
    }

    List mapContent = [];
    if (map["content"] != null) {
      mapContent = map["content"] as List;
    }

    List<Future<MediaEntity>> mediaContentFuture = (mapContent)
        .map((element) => MediaEntity.createEntity(
              element.toString(),
            ))
        .toList();

    List<MediaEntity> mediaContent = await Future.wait(mediaContentFuture);
    bool userLike = (map["likedBy"] as List).length == 1;

    List<String> usersTagged = [];
    if (map["usersTagged"] != null) {
      for (var el in (map["usersTagged"] as List)) {
        usersTagged.add(el["username"]);
      }
    }

    return DiscussionEntity(
      id: map["id"],
      createdOn: DateTime.parse(map["createdOn"]),
      media: mediaContent,
      createdBy: key,
      comments: Nodes.empty(),
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
      userLike: userLike,
      usersTagged: usersTagged,
      title: map["title"],
      text: map["text"],
    );
  }
}
