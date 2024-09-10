import 'package:doko_react/features/User/data/model/post_model.dart';

import 'model.dart';

// basic user info
class UserModel {
  final String id;
  String name;
  final String username;
  String profilePicture;

  UserModel({
    required this.name,
    required this.username,
    required this.profilePicture,
    required this.id,
  });

  static UserModel createModel({required Map map}) {
    return UserModel(
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"],
      id: map["id"],
    );
  }
}

// user profile friend info
class ProfileFriendInfo {
  final List<UserModel> friends;
  final NodeInfo info;

  const ProfileFriendInfo({
    required this.friends,
    required this.info,
  });

  static ProfileFriendInfo createModel({required Map map}) {
    return ProfileFriendInfo(
      friends: (map["edges"] as List)
          .map((post) => UserModel.createModel(
                map: post["node"],
              ))
          .toList(),
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
  });

  static CompleteUserModel createModel({required Map map}) {
    return CompleteUserModel(
      bio: map["bio"] ?? "",
      dob: DateTime.parse(map["dob"]),
      createdOn: DateTime.parse(map["createdOn"]),
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"],
      id: map["id"],
      postsInfo: ProfilePostInfo.createModel(
        map: map["postsConnection"],
      ),
      friendsInfo: ProfileFriendInfo.createModel(
        map: map["friendsConnection"],
      ),
    );
  }
}

class EditUserModel {
  final String name;
  final String bio;
  final String profilePicture;
  final String imgURL;
  final String id;

  const EditUserModel({
    required this.name,
    required this.bio,
    required this.profilePicture,
    required this.imgURL,
    required this.id,
  });
}
