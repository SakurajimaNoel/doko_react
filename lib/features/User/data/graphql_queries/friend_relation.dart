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
      FriendConnectionDetail? connectionDetail, String currentUserId) {
    if (connectionDetail == null) {
      return FriendRelationStatus.unrelated;
    }

    if (connectionDetail.status == FriendStatus.accepted) {
      return FriendRelationStatus.friends;
    }

    if (connectionDetail.requestedBy == currentUserId) {
      return FriendRelationStatus.outgoingReq;
    }

    return FriendRelationStatus.incomingReq;
  }
}
