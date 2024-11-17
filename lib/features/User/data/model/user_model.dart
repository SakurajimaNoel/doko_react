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

  static UserModel createModelInfo({required Map map}) {
    return UserModel(
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"] ?? "",
      id: map["id"],
      signedProfilePicture: "",
    );
  }
}

// complete user info
class CompleteUserModel extends UserModel {
  final String bio;
  final DateTime dob;
  final DateTime createdOn;
  final int postsCount;
  final int friendsCount;
  FriendConnectionDetail? friendRelationDetail;

  CompleteUserModel({
    required this.friendRelationDetail,
    required this.bio,
    required this.dob,
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
    final UserModel user = await UserModel.createModel(map: map);

    List friendConnection = map["friendsConnection"]["edges"] as List;
    FriendConnectionDetail? friendConnectionDetail;

    if (friendConnection.isNotEmpty) {
      friendConnectionDetail =
          FriendConnectionDetail.createModel(friendConnection[0]);
    }

    return CompleteUserModel.fromUserModel(
      user: user,
      friendRelationDetail: friendConnectionDetail,
      bio: map["bio"] ?? "",
      dob: DateTime.parse(map["dob"]),
      createdOn: DateTime.parse(map["createdOn"]),
      friendsCount: map["friendsAggregate"]["count"],
      postsCount: map["postsAggregate"]["count"],
    );
  }
}
