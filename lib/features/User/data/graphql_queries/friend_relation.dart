import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';

enum FriendRelationStatus {
  friends,
  incomingReq,
  outgoingReq,
  unrelated,
}

class FriendRelation {
  static FriendRelationStatus getFriendRelationStatus(
    FriendConnectionDetail? connectionDetail, {
    required String currentUsername,
  }) {
    if (connectionDetail == null) {
      return FriendRelationStatus.unrelated;
    }

    if (connectionDetail.status == FriendStatus.accepted) {
      return FriendRelationStatus.friends;
    }

    if (connectionDetail.requestedByUsername == currentUsername) {
      return FriendRelationStatus.outgoingReq;
    }

    return FriendRelationStatus.incomingReq;
  }
}
