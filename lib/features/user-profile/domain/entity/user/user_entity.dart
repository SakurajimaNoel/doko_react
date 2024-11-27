import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

/// user entity to use with user widget
/// across pages with connection detail
/// this will only will be only used till
/// full profile is not requested, after
/// full profile is requested CompleteUserEntity
/// instance will be used
/// all mutable fields are non final
class UserEntity extends ProfileEntity {
  UserEntity({
    required this.userId,
    required this.username,
    required this.name,
    required this.profilePicture,
    required this.relationInfo,
  });

  final String userId;
  final String username;
  String name;
  StorageResource profilePicture;
  UserRelationInfo? relationInfo;

  // used to update user to user relation info
  void updateRelationInfo(UserRelationInfo? currentRelationInfo) {
    relationInfo = currentRelationInfo;
  }

  static Future<UserEntity> createEntity({required Map map}) async {
    final StorageResource profilePicture =
        await StorageResource.createStorageResource(map["profilePicture"]);

    List friendConnection = map["friendsConnection"]["edges"] as List;
    UserRelationInfo? relationInfo;

    if (friendConnection.isNotEmpty) {
      relationInfo =
          UserRelationInfo.createEntity(map: friendConnection[0]["properties"]);
    }

    return UserEntity(
      userId: map["id"],
      username: map["username"],
      name: map["name"],
      profilePicture: profilePicture,
      relationInfo: relationInfo,
    );
  }
}

class CompleteUserEntity extends UserEntity {
  CompleteUserEntity({
    required super.userId,
    required super.username,
    required super.name,
    required super.profilePicture,
    required super.relationInfo,
    required this.bio,
    required this.dob,
    required this.createdOn,
    required this.postsCount,
    required this.friendsCount,
    required this.friends,
    required this.posts,
  });

  CompleteUserEntity.fromUserEntity({
    required UserEntity user,
    required this.bio,
    required this.dob,
    required this.createdOn,
    required this.postsCount,
    required this.friendsCount,
    required this.friends,
    required this.posts,
  }) : super(
          userId: user.userId,
          username: user.username,
          name: user.name,
          profilePicture: user.profilePicture,
          relationInfo: user.relationInfo,
        );

  String bio;
  final DateTime dob;
  final DateTime createdOn;
  int postsCount;
  int friendsCount;
  Nodes friends;
  Nodes posts;

  void updateUserDetails({
    required String bio,
    required String name,
    required StorageResource profilePicture,
  }) {
    this.bio = bio;
    this.name = name;
    this.profilePicture = profilePicture;
  }

  void updatePostCount(int newPostCount) {
    postsCount = newPostCount;
  }

  void updateFriendsCount(int newFriendsCount) {
    friendsCount = newFriendsCount;
  }

  CompleteUserEntity updateUserEntityValues(UserEntity user) {
    return CompleteUserEntity.fromUserEntity(
      user: user,
      bio: bio,
      dob: dob,
      createdOn: createdOn,
      postsCount: postsCount,
      friendsCount: friendsCount,
      friends: friends,
      posts: posts,
    );
  }

  static Future<CompleteUserEntity> createEntity({required Map map}) async {
    final UserEntity user = await UserEntity.createEntity(
      map: map,
    );

    return CompleteUserEntity.fromUserEntity(
      user: user,
      bio: map["bio"] ?? "",
      dob: DateTime.parse(map["dob"]),
      createdOn: DateTime.parse(map["createdOn"]),
      postsCount: map["postsAggregate"]["count"],
      friendsCount: map["friendsAggregate"]["count"],
      friends: Nodes.empty(),
      posts: Nodes.empty(),
    );
  }
}
