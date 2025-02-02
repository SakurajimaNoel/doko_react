part of 'user_action_bloc.dart';

@immutable
sealed class UserActionEvent {}

// user to post action
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

// user to post action
final class UserActionPostLoadEvent extends UserActionEvent {
  UserActionPostLoadEvent({
    required this.postCount,
    required this.username,
  });

  final int postCount;
  final String username;
}

// user to post action
final class UserActionNewPostEvent extends UserActionEvent {
  UserActionNewPostEvent({
    required this.postId,
    required this.username,
  });

  final String username;
  final String postId;
}

final class UserActionNewPostRemoteEvent extends UserActionEvent {
  UserActionNewPostRemoteEvent({
    required this.postId,
    required this.username,
  });

  final String username;
  final String postId;
}

// user to comment action
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

// user to comment action
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

// user to post action
final class UserActionPostRefreshEvent extends UserActionEvent {
  UserActionPostRefreshEvent({
    required this.postId,
  });

  final String postId;
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

// fetch comment by commentId for streaming
final class UserActionGetCommentByIdEvent extends UserActionEvent {
  UserActionGetCommentByIdEvent({
    required this.username,
    required this.commentId,
  });

  final String username;
  final String commentId;
}
