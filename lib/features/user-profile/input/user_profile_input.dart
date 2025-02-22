import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';

class UserNodeLikeActionInput {
  const UserNodeLikeActionInput({
    required this.nodeId,
    required this.username,
    required this.userLike,
    required this.nodeType,
  });

  final String nodeId;
  final String username;
  final DokiNodeType nodeType;
  final bool userLike;
}

class UserToUserRelationDetails {
  const UserToUserRelationDetails({
    required this.initiator,
    required this.participant,
    required this.username,
    required this.currentUsername,
  });

  final String initiator;
  final String participant;

  // used to update local graph and getting relation info
  final String username;
  final String currentUsername;
}
