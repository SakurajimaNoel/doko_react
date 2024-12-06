class UserPostLikeActionInput {
  const UserPostLikeActionInput({
    required this.postId,
    required this.username,
  });

  final String postId;
  final String username;
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
