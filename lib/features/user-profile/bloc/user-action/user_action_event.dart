part of 'user_action_bloc.dart';

@immutable
sealed class UserActionEvent {}

final class UserActionNodeLikeEvent extends UserActionEvent {
  UserActionNodeLikeEvent({
    required this.username,
    required this.nodeId,
    required this.nodeType,
    required this.client,
    required this.remotePayload,
    required this.userLike,
  });

  final String nodeId;
  final DokiNodeType nodeType;
  final String username;
  final bool userLike;
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
    required this.usersTagged,
  });

  final String username;
  final String postId;
  final List<String> usersTagged;
}

final class UserActionNewDiscussionEvent extends UserActionEvent {
  UserActionNewDiscussionEvent({
    required this.discussionId,
    required this.username,
    required this.usersTagged,
  });

  final String username;
  final String discussionId;
  final List<String> usersTagged;
}

final class UserActionNewPollEvent extends UserActionEvent {
  UserActionNewPollEvent({
    required this.pollId,
    required this.username,
    required this.usersTagged,
  });

  final String username;
  final String pollId;
  final List<String> usersTagged;
}

final class UserActionNewPostRemoteEvent extends UserActionEvent {
  UserActionNewPostRemoteEvent({
    required this.postId,
    required this.username,
    required this.usersTagged,
    required this.nodeBy,
  });

  final String username;
  final String nodeBy;
  final String postId;
  final List<String> usersTagged;
}

final class UserActionNewDiscussionRemoteEvent extends UserActionEvent {
  UserActionNewDiscussionRemoteEvent({
    required this.discussionId,
    required this.username,
    required this.usersTagged,
    required this.nodeBy,
  });

  final String username;
  final String nodeBy;
  final String discussionId;
  final List<String> usersTagged;
}

final class UserActionNewPollRemoteEvent extends UserActionEvent {
  UserActionNewPollRemoteEvent({
    required this.pollId,
    required this.username,
    required this.usersTagged,
    required this.nodeBy,
  });

  final String username;
  final String nodeBy;
  final String pollId;
  final List<String> usersTagged;
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

final class UserActionGetPollByIdEvent extends UserActionEvent {
  UserActionGetPollByIdEvent({
    required this.username,
    required this.pollId,
  });

  final String username;
  final String pollId;
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

/// add vote to to poll
final class UserActionAddVoteToPollEvent extends UserActionEvent {
  UserActionAddVoteToPollEvent({
    required this.pollId,
    required this.username,
    required this.option,
  });

  final String pollId;
  final String username;
  final PollOption option;
}
