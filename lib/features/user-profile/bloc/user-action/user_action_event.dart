part of 'user_action_bloc.dart';

@immutable
sealed class UserActionEvent {}

final class UserActionUpdateEvent extends UserActionEvent {
  UserActionUpdateEvent({
    required this.name,
    required this.bio,
    required this.profilePicture,
  });

  final String name;
  final String bio;
  final String profilePicture;
}

final class UserActionPostLikeActionEvent extends UserActionEvent {
  UserActionPostLikeActionEvent({
    required this.postId,
    required this.userLike,
    required this.username,
  });

  final String postId;
  final bool userLike;
  final String username;
}

final class UserActionPostLoadEvent extends UserActionEvent {
  UserActionPostLoadEvent({
    required this.postCount,
    required this.username,
  });

  final int postCount;
  final String username;
}

final class UserActionNewPostEvent extends UserActionEvent {
  UserActionNewPostEvent({
    required this.postId,
  });

  final String postId;
}

final class UserActionFriendLoadEvent extends UserActionEvent {
  UserActionFriendLoadEvent({
    required this.friendsCount,
    required this.username,
  });

  final int friendsCount;
  final String username;
}

// user to user relation
final class UserActionCreateFriendRelationEvent extends UserActionEvent {
  UserActionCreateFriendRelationEvent({
    required this.currentUsername,
    required this.username,
  });

  final String currentUsername;
  final String username;
}

final class UserActionAcceptFriendRelationEvent extends UserActionEvent {
  UserActionAcceptFriendRelationEvent({
    required this.currentUsername,
    required this.username,
    required this.requestedBy,
  });

  final String currentUsername;
  final String username;

  // requested by and username will be equal
  final String requestedBy;
}

final class UserActionRemoveFriendRelationEvent extends UserActionEvent {
  UserActionRemoveFriendRelationEvent({
    required this.currentUsername,
    required this.username,
    required this.requestedBy,
  });

  final String currentUsername;
  final String username;

  // requested by value is ambiguous
  final String requestedBy;
}

final class UserActionUserRefreshEvent extends UserActionEvent {
  UserActionUserRefreshEvent({
    required this.username,
  });

  final String username;
}

// comment
final class UserActionCommentLikeActionEvent extends UserActionEvent {
  UserActionCommentLikeActionEvent({
    required this.commentId,
    required this.userLike,
    required this.username,
  });

  final String commentId;
  final bool userLike;
  final String username;
}

final class UserActionNewCommentEvent extends UserActionEvent {
  UserActionNewCommentEvent({
    required this.commentId,
    required this.userLike,
    required this.commentsCount,
    required this.likesCount,
    required this.targetId,
  });

  final String commentId;
  final bool userLike;
  final int likesCount;
  final int commentsCount;
  final String targetId;
}

// post refresh
final class UserActionPostRefreshEvent extends UserActionEvent {
  UserActionPostRefreshEvent({
    required this.postId,
  });

  final String postId;
}

// fetch user by username for new messages
final class UserActionGetUserByUsernameEvent extends UserActionEvent {
  UserActionGetUserByUsernameEvent({
    required this.username,
    required this.currentUser,
  });

  final String username;
  final String currentUser;
}

// fetch post by postId for new messages
final class UserActionGetPostByIdEvent extends UserActionEvent {
  UserActionGetPostByIdEvent({
    required this.username,
    required this.postId,
  });

  final String username;
  final String postId;
}
