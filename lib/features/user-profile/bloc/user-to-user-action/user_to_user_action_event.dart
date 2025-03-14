part of 'user_to_user_action_bloc.dart';

sealed class UserToUserActionEvent {
  const UserToUserActionEvent();
}

final class UserToUserUpdateProfileEvent extends UserToUserActionEvent {
  const UserToUserUpdateProfileEvent({
    required this.username,
    required this.name,
    required this.bio,
    required this.profilePicture,
  });

  final String name;
  final String bio;
  final String profilePicture;
  final String username;
}

final class UserToUserActionNodesLoadEvent extends UserToUserActionEvent {
  const UserToUserActionNodesLoadEvent({
    required this.itemCount,
    required this.username,
    required this.nodeType,
  });

  final int itemCount;
  final String username;
  final DokiNodeType nodeType;
}

final class UserToUserActionCreateFriendRelationEvent
    extends UserToUserActionEvent {
  const UserToUserActionCreateFriendRelationEvent({
    required this.currentUsername,
    required this.username,
  });

  final String currentUsername;
  final String username;
}

final class UserToUserActionAcceptFriendRelationEvent
    extends UserToUserActionEvent {
  const UserToUserActionAcceptFriendRelationEvent({
    required this.currentUsername,
    required this.username,
    required this.requestedBy,
  });

  final String currentUsername;
  final String username;

  // requested by and username will be equal
  final String requestedBy;
}

final class UserToUserActionRemoveFriendRelationEvent
    extends UserToUserActionEvent {
  const UserToUserActionRemoveFriendRelationEvent({
    required this.currentUsername,
    required this.username,
    required this.requestedBy,
  });

  final String currentUsername;
  final String username;

  // requested by value is ambiguous
  final String requestedBy;
}

final class UserToUserActionUserRefreshEvent extends UserToUserActionEvent {
  const UserToUserActionUserRefreshEvent({
    required this.username,
  });

  final String username;
}

final class UserToUserActionGetUserByUsernameEvent
    extends UserToUserActionEvent {
  const UserToUserActionGetUserByUsernameEvent({
    required this.username,
    required this.currentUser,
  });

  final String username;
  final String currentUser;
}

final class UserToUserActionUserSendFriendRequestRemoteEvent
    extends UserToUserActionEvent {
  const UserToUserActionUserSendFriendRequestRemoteEvent({
    required this.username,
    required this.request,
  });

  final String username;
  final UserSendFriendRequest request;
}

final class UserToUserActionUserAcceptsFriendRequestRemoteEvent
    extends UserToUserActionEvent {
  const UserToUserActionUserAcceptsFriendRequestRemoteEvent({
    required this.username,
    required this.request,
  });

  final String username;
  final UserAcceptFriendRequest request;
}

final class UserToUserActionUserRemovesFriendRelationRemoteEvent
    extends UserToUserActionEvent {
  const UserToUserActionUserRemovesFriendRelationRemoteEvent({
    required this.username,
    required this.relation,
  });

  final String username;
  final UserRemovesFriendRelation relation;
}

// update user profile remote event
final class UserToUserUpdateProfileRemoteEvent extends UserToUserActionEvent {
  const UserToUserUpdateProfileRemoteEvent({
    required this.username,
    required this.name,
    required this.bio,
    required this.profilePicture,
  });

  final String name;
  final String bio;
  final String profilePicture;
  final String username;
}
