import 'package:doko_react/core/config/graphql/queries/graphql_query_constants.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';

enum UserToUserRelation {
  friends,
  incomingReq,
  outgoingReq,
  unrelated,
}

UserToUserRelation getUserToUserRelation(
  UserRelationInfo? relationInfo, {
  required String currentUsername,
}) {
  if (relationInfo == null) return UserToUserRelation.unrelated;

  if (relationInfo.status == FriendStatus.accepted) {
    return UserToUserRelation.friends;
  }

  if (relationInfo.requestedBy == currentUsername) {
    return UserToUserRelation.outgoingReq;
  }

  return UserToUserRelation.incomingReq;
}
