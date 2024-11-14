import 'package:doko_react/features/User/data/model/post_model.dart';

import 'friend_model.dart';
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
        await StorageUtils.generatePreSignedURL(map["profilePicture"] ?? "");

    return UserModel(
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"] ?? "",
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
  int postsCount;
  int friendsCount;

  CompleteUserModel({
    required this.friendRelationDetail,
    required this.bio,
    required this.dob,
    required this.postsInfo,
    required this.createdOn,
    required super.name,
    required super.username,
    required super.profilePicture,
    required super.id,
    required super.signedProfilePicture,
    required this.friendsCount,
    required this.postsCount,
  });

  CompleteUserModel.fromUserModel({
    required UserModel user,
    required this.friendRelationDetail,
    required this.bio,
    required this.postsInfo,
    required this.createdOn,
    required this.dob,
    required this.postsCount,
    required this.friendsCount,
  }) : super(
          name: user.name,
          username: user.username,
          profilePicture: user.profilePicture,
          id: user.id,
          signedProfilePicture: user.signedProfilePicture,
        );

  static Future<CompleteUserModel> createModel({required Map map}) async {
    // user model
    Future<UserModel> futureUser = UserModel.createModel(map: map);

    // user posts
    Future<ProfilePostInfo> futurePostInfo = ProfilePostInfo.createModel(
      map: map["postsConnection"],
    );

    final results = await Future.wait([
      futureUser,
      futurePostInfo,
    ]);

    List friendConnection = map["friends"] as List;
    FriendConnectionDetail? friendConnectionDetail;

    if (friendConnection.isNotEmpty) {
      friendConnectionDetail = FriendConnectionDetail.createModel(
          friendConnection[0]["friendsConnection"]["edges"][0]["properties"]);
    }

    return CompleteUserModel.fromUserModel(
      user: results[0] as UserModel,
      friendRelationDetail: friendConnectionDetail,
      bio: map["bio"] ?? "",
      dob: DateTime.parse(map["dob"]),
      createdOn: DateTime.parse(map["createdOn"]),
      postsInfo: results[1] as ProfilePostInfo,
      friendsCount: map["friendsConnection"]["totalCount"],
      postsCount: map["postsConnection"]["totalCount"],
    );
  }
}
