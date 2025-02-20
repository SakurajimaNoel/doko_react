part of 'user_action_bloc.dart';

@immutable
sealed class UserActionEvent {}

// user to post action
final class UserActionPostLikeActionEvent extends UserActionEvent {
  UserActionPostLikeActionEvent({
    required this.postId,
    required this.userLike,
    required this.username,
    required this.client,
    required this.remotePayload,
  });

  final String postId;
  final bool userLike;
  final String username;

  // used to send to remote users
  final Client? client;
  final UserNodeLikeAction remotePayload;
}

// user to post action
final class UserActionTimelineLoadEvent extends UserActionEvent {
  UserActionTimelineLoadEvent({
    required this.itemCount,
    required this.username,
  });

  final int itemCount;
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

final class UserActionNewDiscussionEvent extends UserActionEvent {
  UserActionNewDiscussionEvent({
    required this.discussionId,
    required this.username,
  });

  final String username;
  final String discussionId;
}

final class UserActionNewPostRemoteEvent extends UserActionEvent {
  UserActionNewPostRemoteEvent({
    required this.postId,
    required this.username,
  });

  final String username;
  final String postId;
}

final class UserActionNewDiscussionRemoteEvent extends UserActionEvent {
  UserActionNewDiscussionRemoteEvent({
    required this.discussionId,
    required this.username,
  });

  final String username;
  final String discussionId;
}

// user to comment action
final class UserActionCommentLikeActionEvent extends UserActionEvent {
  UserActionCommentLikeActionEvent({
    required this.commentId,
    required this.userLike,
    required this.username,
    required this.client,
    required this.remotePayload,
  });

  final String commentId;
  final bool userLike;
  final String username;
  final Client? client;
  final UserNodeLikeAction remotePayload;
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
final class UserActionPrimaryNodeRefreshEvent extends UserActionEvent {
  UserActionPrimaryNodeRefreshEvent({
    required this.nodeId,
  });

  final String nodeId;
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

// fetch post by postId for new messages
final class UserActionGetDiscussionByIdEvent extends UserActionEvent {
  UserActionGetDiscussionByIdEvent({
    required this.username,
    required this.discussionId,
  });

  final String username;
  final String discussionId;
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

// remote like action
final class UserActionNodeLikeRemoteEvent extends UserActionEvent {
  UserActionNodeLikeRemoteEvent({
    required this.payload,
    required this.username,
  });

  final UserNodeLikeAction payload;
  final String username;
}

/// node reply highlight event
final class UserActionNodeHighlightEvent extends UserActionEvent {
  UserActionNodeHighlightEvent({
    required this.nodeId,
  });

  final String nodeId;
}

// new comment on user related nodes
final class UserActionNewSecondaryNodeRemoteEvent extends UserActionEvent {
  UserActionNewSecondaryNodeRemoteEvent({
    required this.payload,
  });

  final UserCreateSecondaryNode payload;
}
