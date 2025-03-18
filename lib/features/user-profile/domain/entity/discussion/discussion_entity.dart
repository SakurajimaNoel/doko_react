import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/media/media_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class DiscussionEntity implements UserActionEntityWithMediaItems {
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

  @override
  final String id;
  final String title;
  @override
  final DateTime createdOn;
  @override
  final String createdBy;
  final List<MediaEntity> media;
  final String text;
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
  List<MediaEntity> get mediaItems => media;

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
    if (map["media"] != null) {
      mapContent = map["media"] as List;
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

    return DiscussionEntity(
      id: map["id"],
      createdOn: DateTime.parse(map["createdOn"]).toLocal(),
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

  @override
  String getNodeKey() {
    return generateDiscussionNodeKey(id);
  }
}
