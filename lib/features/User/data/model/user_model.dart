import 'package:doko_react/features/User/data/model/post_model.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String profilePicture;

  const UserModel({
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

class CompleteUserModel extends UserModel {
  final String bio;
  final DateTime dob;
  final DateTime createdOn;
  final List<PostModel> posts;
  final List<UserModel> friends;

  const CompleteUserModel({
    required this.bio,
    required this.dob,
    required this.posts,
    required this.friends,
    required this.createdOn,
    required super.name,
    required super.username,
    required super.profilePicture,
    required super.id,
  });

  static CompleteUserModel createModel({required Map map}) {
    return CompleteUserModel(
      bio: map["bio"],
      dob: DateTime.parse(map["dob"]),
      createdOn: DateTime.parse(map["createdOn"]),
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"],
      id: map["id"],
      posts: (map["posts"] as List)
          .map((postMap) => PostModel.createModel(
                map: postMap,
              ))
          .toList(),
      friends: (map["friends"] as List)
          .map((userMap) => UserModel.createModel(
                map: userMap,
              ))
          .toList(),
    );
  }
}
