import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/media/media_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class PostEntity implements NodeWithMediaItems {
  PostEntity({
    required this.id,
    required this.caption,
    required this.createdOn,
    required this.content,
    required this.createdBy,
    required this.comments,
    required this.likesCount,
    required this.commentsCount,
    required this.userLike,
    required this.usersTagged,
  });

  final String id;
  final String caption;
  final DateTime createdOn;
  final List<MediaEntity> content;
  final String createdBy; // reference to user key user:username
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

  // @override
  // Nodes get nodeComments => comments;

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

  /// create different methods when user is already present in user graph
  /// and when user is not present
  static Future<PostEntity> createEntity({required Map map}) async {
    /// check if user:username exists in map
    /// if not add the user to map and save reference
    /// when fetching post for user profile user will always
    /// be there so no need to get user info in every post item
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

    return PostEntity(
      id: map["id"],
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      content: mediaContent,
      createdBy: key,
      comments: Nodes.empty(),
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
      userLike: userLike,
      usersTagged: usersTagged,
    );
  }
}
