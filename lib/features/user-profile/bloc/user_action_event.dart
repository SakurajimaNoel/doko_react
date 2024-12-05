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
