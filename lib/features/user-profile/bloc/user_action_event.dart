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

// final class UserActionPostActionEvent extends UserActionEvent {
//   UserActionPostActionEvent({
//     required this.postId,
//     required this.userLike,
//     required this.likesCount,
//     required this.commentsCount,
//   });
//
//   final String postId;
//   final int likesCount;
//   final bool userLike;
//   final int commentsCount;
// }

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
