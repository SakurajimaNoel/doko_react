import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/media/media_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class PostEntity implements UserActionEntityWithMediaItems {
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

  @override
  final String id;
  final String caption;
  @override
  final DateTime createdOn;
  final List<MediaEntity> content;
  @override
  final String createdBy; // reference to user key user:username
  @override
  final List<UsersTagged> usersTagged;

  @override
  int likesCount;

  @override
  int commentsCount;

  @override
  bool userLike;

  @override
  Nodes comments;

  @override
  int currDisplay = 0;

  @override
  void updateDisplayItem(int item) {
    currDisplay = item;
  }

  @override
  void updateUserLikeStatus(bool userLike) {
    this.userLike = userLike;
  }

  @override
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

    List<UsersTagged> usersTagged = [];
    if (map["usersTagged"] != null) {
      for (var el in (map["usersTagged"] as List)) {
        String username = el["username"];
        StorageResource profilePicture =
            await StorageResource.createStorageResource(el["profilePicture"]);
        usersTagged.add(UsersTagged(
          username: username,
          profilePicture: profilePicture,
        ));
      }
    }

    return PostEntity(
      id: map["id"],
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]).toLocal(),
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
