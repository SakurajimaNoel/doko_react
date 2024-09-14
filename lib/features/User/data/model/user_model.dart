import 'package:doko_react/features/User/data/model/post_model.dart';

import 'friend_modal.dart';
import 'model.dart';

// basic user info
class UserModel {
  final String id;
  String name;
  final String username;
  String profilePicture;
  String signedProfilePicture;

  UserModel({
    required this.name,
    required this.username,
    required this.profilePicture,
    required this.id,
    required this.signedProfilePicture,
  });

  static Future<UserModel> createModel({required Map map}) async {
    String signedProfilePicture =
        await StorageUtils.generatePreSignedURL(map["profilePicture"]);

    return UserModel(
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"],
      id: map["id"],
      signedProfilePicture: signedProfilePicture,
    );
  }
}

// complete user info
class CompleteUserModel extends UserModel {
  FriendConnectionDetail? friendRelationDetail;
  String bio;
  final DateTime dob;
  final DateTime createdOn;
  final ProfilePostInfo postsInfo;
  final ProfileFriendInfo friendsInfo;

  CompleteUserModel({
    required this.friendRelationDetail,
    required this.bio,
    required this.dob,
    required this.postsInfo,
    required this.friendsInfo,
    required this.createdOn,
    required super.name,
    required super.username,
    required super.profilePicture,
    required super.id,
    required super.signedProfilePicture,
  });

  static Future<CompleteUserModel> createModel({required Map map}) async {
    // user profile picture
    Future<String> futureSignedProfilePicture =
        StorageUtils.generatePreSignedURL(map["profilePicture"]);

    // user posts
    Future<ProfilePostInfo> futurePostInfo = ProfilePostInfo.createModel(
      map: map["postsConnection"],
    );

    // user friends
    Future<ProfileFriendInfo> futureFriendInfo =
        ProfileFriendInfo.createModel(map: map["friendsConnection"]);

    final results = await Future.wait([
      futureSignedProfilePicture,
      futurePostInfo,
      futureFriendInfo,
    ]);

    List friendConnection = map["friends"] as List;
    FriendConnectionDetail? friendConnectionDetail;

    if (friendConnection.isNotEmpty) {
      friendConnectionDetail = FriendConnectionDetail.createModel(
          friendConnection[0]["friendsConnection"]["edges"][0]);
    }

    return CompleteUserModel(
      friendRelationDetail: friendConnectionDetail,
      bio: map["bio"] ?? "",
      dob: DateTime.parse(map["dob"]),
      createdOn: DateTime.parse(map["createdOn"]),
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"],
      signedProfilePicture: results[0] as String,
      id: map["id"],
      postsInfo: results[1] as ProfilePostInfo,
      friendsInfo: results[2] as ProfileFriendInfo,
    );
  }
}
