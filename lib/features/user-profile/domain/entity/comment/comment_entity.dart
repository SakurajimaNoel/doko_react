import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class CommentEntity extends GraphEntity {
  CommentEntity({
    required this.id,
    required this.createdOn,
    required this.commentBy,
    required this.media,
    required this.content,
    required this.mentions,
    required this.comments,
    required this.likesCount,
    required this.commentsCount,
    required this.userLike,
    required this.showReplies,
  });

  final String id;
  final DateTime createdOn;
  final String commentBy;
  final StorageResource media; // also handle giphy url
  final List<String> content;
  final List<String> mentions;
  int likesCount;
  int commentsCount;
  bool userLike;
  Nodes comments;

  bool showReplies;

  @Deprecated("use individual methods")
  void updateUserLikes(bool userLike, int likesCount) {
    this.likesCount = likesCount;
    this.userLike = userLike;
  }

  void updateUserLikeStatus(bool userLike) {
    this.userLike = userLike;
  }

  void updateLikeCount(int likesCount) {
    this.likesCount = likesCount;
  }

  void updateCommentsCount(int newCommentsCount) {
    commentsCount = newCommentsCount;
  }

  static Future<CommentEntity> createEntity({required Map map}) async {
    /// check if user:username exists in map
    /// if not add the user to map and save reference
    final String commentByUsername = map["commentBy"]["username"];
    final String userKey = generateUserNodeKey(commentByUsername);

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(userKey)) {
      UserEntity user = await UserEntity.createEntity(map: map["commentBy"]);
      String key = generateUserNodeKey(user.username);

      graph.addEntity(key, user);
    }

    bool userLike = (map["likedBy"] as List).length == 1;

    StorageResource media;
    if (validateUrl(map["media"])) {
      media = StorageResource.forGeneralResource(
        bucketPath: map["media"],
        accessURI: map["media"],
      );
    } else {
      media = await StorageResource.createStorageResource(map["media"]);
    }

    List mapMentions = [];
    if (map["mentions"] != null) {
      mapMentions = map["mentions"] as List;
    }
    List<String> mentions =
        mapMentions.map((element) => element.toString()).toList();

    List mapContent = [];
    if (map["content"] != null) {
      mapContent = map["content"] as List;
    }
    List<String> content =
        mapContent.map((element) => element.toString()).toList();

    return CommentEntity(
      id: map["id"],
      createdOn: DateTime.parse(map["createdOn"]),
      commentBy: "user:$commentByUsername",
      media: media,
      content: content,
      mentions: mentions,
      likesCount: map["likedByConnection"]["totalCount"],
      userLike: userLike,
      commentsCount: map["commentsConnection"]["totalCount"],
      comments: Nodes.empty(),
      showReplies: false,
    );
  }
}
