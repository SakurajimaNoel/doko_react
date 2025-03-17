import 'dart:async';

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
class UserEntity implements GraphEntity {
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
  int? profileHeight;

  // used to update user to user relation info
  void updateRelationInfo(UserRelationInfo? currentRelationInfo) {
    relationInfo = currentRelationInfo;
  }

  static Future<UserEntity> createEntity({required Map map}) async {
    final StorageResource profilePicture =
        await StorageResource.createStorageResource(map["profilePicture"]);

    UserRelationInfo? relationInfo;
    if (map.containsKey("friendsConnection")) {
      List friends = map["friendsConnection"]["edges"] as List;

      if (friends.isNotEmpty) {
        relationInfo = UserRelationInfo.createEntity(
          map: friends[0]["properties"],
        );
      }
    }

    return UserEntity(
      userId: map["id"],
      username: map["username"],
      name: map["name"],
      profilePicture: profilePicture,
      relationInfo: relationInfo,
    );
  }

  static UserRelationInfo? getRelationInfo(Map map) {
    UserRelationInfo? relationInfo;

    if (map.containsKey("friendsConnection")) {
      List friends = map["friendsConnection"]["edges"] as List;

      if (friends.isNotEmpty) {
        relationInfo = UserRelationInfo.createEntity(
          map: friends[0]["properties"],
        );
      }
    }

    return relationInfo;
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
    required this.discussions,
    required this.polls,
    required this.timeline,
    required this.pollCount,
    required this.discussionCount,
    required this.pageCount,
    required this.pages,
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
    required this.discussions,
    required this.polls,
    required this.timeline,
    required this.pollCount,
    required this.discussionCount,
    required this.pageCount,
    required this.pages,
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
  int discussionCount;
  int pollCount;
  int pageCount;

  Nodes friends;
  Nodes posts;
  Nodes discussions;
  Nodes polls;
  Nodes pages;

  Nodes timeline;

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

  void updateDiscussionCount(int newDiscussionCount) {
    discussionCount = newDiscussionCount;
  }

  void updatePollCount(int newPollCount) {
    pollCount = newPollCount;
  }

  void updateFriendsCount(int newFriendsCount) {
    friendsCount = newFriendsCount;
  }

  void updatePagesCount(int newPagesCount) {
    pageCount = newPagesCount;
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
      polls: polls,
      discussions: discussions,
      timeline: timeline,
      discussionCount: discussionCount,
      pollCount: pollCount,
      pageCount: pageCount,
      pages: pages,
    );
  }

  static Future<CompleteUserEntity> createEntity({required Map map}) async {
    final UserEntity user = await UserEntity.createEntity(
      map: map,
    );

    return CompleteUserEntity.fromUserEntity(
      user: user,
      bio: map["bio"] ?? "",
      dob: DateTime.parse(map["dob"]), // this is only date string
      createdOn: DateTime.parse(map["createdOn"]).toLocal(),
      postsCount: map["postsAggregate"]["count"],
      friendsCount: map["friendsAggregate"]["count"],
      discussionCount: map["discussionsAggregate"]["count"],
      pollCount: map["pollsAggregate"]["count"],
      friends: Nodes.empty(),
      posts: Nodes.empty(),
      discussions: Nodes.empty(),
      polls: Nodes.empty(),
      timeline: Nodes.empty(),
      pageCount: 0,
      pages: Nodes.empty(),
    );
  }
}
