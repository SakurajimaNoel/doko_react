import 'package:doko_react/features/User/data/model/user_model.dart';

import 'model.dart';

class FriendConnectionDetail {
  final String requestedBy;
  String status;

  void updateStatus(String status) {
    this.status = status;
  }

  FriendConnectionDetail({
    required this.requestedBy,
    required this.status,
  });

  static FriendConnectionDetail createModel(Map map) {
    return FriendConnectionDetail(
      requestedBy: map["requestedBy"],
      status: map["status"],
    );
  }
}

// user friend model
class FriendUserModel extends UserModel {
  final FriendConnectionDetail? friendRelationDetail;

  FriendUserModel({
    required this.friendRelationDetail,
    required super.name,
    required super.username,
    required super.profilePicture,
    required super.id,
    required super.signedProfilePicture,
  });

  FriendUserModel.fromUserModel({
    required this.friendRelationDetail,
    required UserModel user,
  }) : super(
          name: user.name,
          username: user.username,
          profilePicture: user.profilePicture,
          id: user.id,
          signedProfilePicture: user.signedProfilePicture,
        );

  static Future<FriendUserModel> createModel({required Map map}) async {
    Map userMap = map["node"];
    UserModel user = await UserModel.createModel(map: userMap);

    List friendConnection = userMap["friendsConnection"]["edges"];
    FriendConnectionDetail? friendConnectionDetail;

    if (friendConnection.isNotEmpty) {
      friendConnectionDetail =
          FriendConnectionDetail.createModel(friendConnection[0]);
    }

    return FriendUserModel.fromUserModel(
      friendRelationDetail: friendConnectionDetail,
      user: user,
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
