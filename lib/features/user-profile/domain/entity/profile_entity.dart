import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/features/user-profile/domain/media/media_entity.dart';

/// base class to use with user graph
abstract class GraphEntity {
  String getNodeKey();
}

/// base class for nodes that allow user actions in it
abstract class GraphEntityWithUserAction implements GraphEntity {
  Nodes get comments;
  int get commentsCount;
  int get likesCount;
  bool get userLike;
  String get id;
  DateTime get createdOn;
  String get createdBy;
  List<UsersTagged> get usersTagged;

  void updateCommentsCount(int count);

  void updateLikeCount(int count);

  void updateUserLikeStatus(bool userLike);
}

abstract class UserActionEntityWithMediaItems
    implements GraphEntityWithUserAction {
  int get currDisplay;

  void updateDisplayItem(int item);

  List<MediaEntity> get mediaItems;
}

final class UsersTagged {
  const UsersTagged({
    required this.username,
    required this.profilePicture,
  });

  final String username;
  final StorageResource profilePicture;
}
