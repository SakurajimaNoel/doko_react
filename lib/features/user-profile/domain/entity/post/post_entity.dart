import 'package:doko_react/core/global/cache/cache.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

part 'post_content_entity.dart';

class PostEntity extends ProfileEntity {
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
  });

  final String id;
  final String caption;
  final DateTime createdOn;
  final List<PostContentEntity> content;
  final String createdBy; // reference to user key user:username
  int likesCount;
  int commentsCount;
  bool userLike;
  final Nodes comments;

  void updateUserLikes(bool userLike, int likesCount) {
    this.likesCount = likesCount;
    this.userLike = userLike;
  }

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

    List<Future<PostContentEntity>> postContentFuture = (mapContent)
        .map((element) => PostContentEntity.createEntity(
              element.toString(),
            ))
        .toList();

    List<PostContentEntity> results = await Future.wait(postContentFuture);
    bool userLike = (map["likedBy"] as List).length == 1;

    return PostEntity(
      id: map["id"],
      caption: map["caption"],
      createdOn: DateTime.parse(map["createdOn"]),
      content: results,
      createdBy: key,
      comments: Nodes.empty(),
      likesCount: map["likedByConnection"]["totalCount"],
      commentsCount: map["commentsConnection"]["totalCount"],
      userLike: userLike,
    );
  }
}
