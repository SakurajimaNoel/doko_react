import 'package:doko_react/features/User/data/model/post_model.dart';

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

// user friend model
class FriendUserModel extends UserModel {
  final String requestedBy;

  FriendUserModel({
    required this.requestedBy,
    required super.name,
    required super.username,
    required super.profilePicture,
    required super.id,
    required super.signedProfilePicture,
  });

  static Future<FriendUserModel> createModel({required Map map}) async {
    Map user = map["node"];
    String signedProfilePicture =
        await StorageUtils.generatePreSignedURL(user["profilePicture"]);

    return FriendUserModel(
      name: user["name"],
      username: user["username"],
      profilePicture: user["profilePicture"],
      id: user["id"],
      signedProfilePicture: signedProfilePicture,
      requestedBy: map["requestedBy"],
    );
  }
}

// user profile friend info
class ProfileFriendInfo {
  final List<FriendUserModel> friends;
  final NodeInfo info;

  const ProfileFriendInfo({
    required this.friends,
    required this.info,
  });

  void addFriends(List<FriendUserModel> newFriends) {
    friends.addAll(newFriends);
  }

  static Future<ProfileFriendInfo> createModel({required Map map}) async {
    List<Future<FriendUserModel>> futureFriendsModel =
        (map["edges"] as List).map((user) async {
      FriendUserModel friend = await FriendUserModel.createModel(map: user);
      return friend;
    }).toList();

    List<FriendUserModel> friends = await Future.wait(futureFriendsModel);

    return ProfileFriendInfo(
      friends: friends,
      info: NodeInfo.createModel(
        map: map["pageInfo"],
      ),
    );
  }
}

// complete user info
class CompleteUserModel extends UserModel {
  String bio;
  final DateTime dob;
  final DateTime createdOn;
  final ProfilePostInfo postsInfo;
  final ProfileFriendInfo friendsInfo;

  CompleteUserModel({
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
    Future<ProfilePostInfo> futurePostInfo = ProfilePostInfo.createModel(
      map: map["postsConnection"],
    );

    Future<String> futureSignedProfilePicture =
        StorageUtils.generatePreSignedURL(map["profilePicture"]);

    Future<ProfileFriendInfo> futureFriendInfo =
        ProfileFriendInfo.createModel(map: map["friendsConnection"]);

    final results = await Future.wait([
      futureSignedProfilePicture,
      futurePostInfo,
      futureFriendInfo,
    ]);

    return CompleteUserModel(
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
