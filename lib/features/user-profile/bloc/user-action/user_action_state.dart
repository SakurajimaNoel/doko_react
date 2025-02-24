part of 'user_action_bloc.dart';

@immutable
sealed class UserActionState extends Equatable {}

final class UserActionInitial extends UserActionState {
  @override
  List<Object?> get props => [];
}

// this is used for timeline render
final class UserActionNewContentState extends UserActionState {
  UserActionNewContentState({required this.nodeId});

  final String nodeId;

  @override
  List<Object?> get props => [nodeId];
}

class UserActionLoadTimelineState extends UserActionState {
  UserActionLoadTimelineState({
    required this.itemCount,
    required this.username,
  });

  final String username;
  final int itemCount;

  @override
  List<Object?> get props => [username, itemCount];
}

// base class for new node state
final class UserActionNewRootNodeState extends UserActionState {
  UserActionNewRootNodeState({
    required this.nodeId,
    required this.username,
    required this.usersTagged,
  });

  final String nodeId;
  final String username;
  final List<String> usersTagged;

  @override
  List<Object?> get props => [nodeId, username, usersTagged];
}

final class UserActionNewPostState extends UserActionNewRootNodeState {
  UserActionNewPostState({
    required super.nodeId,
    required super.username,
    required super.usersTagged,
  });

  @override
  List<Object?> get props => [nodeId, username, usersTagged];
}

final class UserActionNewDiscussionState extends UserActionNewRootNodeState {
  UserActionNewDiscussionState({
    required super.nodeId,
    required super.username,
    required super.usersTagged,
  });

  @override
  List<Object?> get props => [nodeId, username, usersTagged];
}

final class UserActionNewPollState extends UserActionNewRootNodeState {
  UserActionNewPollState({
    required super.nodeId,
    required super.username,
    required super.usersTagged,
  });

  @override
  List<Object?> get props => [nodeId, username, usersTagged];
}

/// user post action state
/// used when updating ui for post action
/// when new comment is added or like is changed
/// this will be used with both post and comment
class UserActionNodeActionState extends UserActionState {
  UserActionNodeActionState({
    required this.nodeId,
    required this.userLike,
    required this.likesCount,
    required this.commentsCount,
  });

  final String nodeId;
  final int likesCount;
  final bool userLike;
  final int commentsCount;

  @override
  List<Object?> get props => [nodeId, likesCount, userLike, commentsCount];
}

// individual post related states
class UserActionNewCommentState extends UserActionState {
  UserActionNewCommentState({
    required this.nodeId,
  }) : now = DateTime.now();

  final String nodeId;
  final DateTime now;

  @override
  List<Object?> get props => [nodeId, now];
}

class UserActionPrimaryNodeRefreshState extends UserActionState {
  UserActionPrimaryNodeRefreshState({
    required this.nodeId,
  }) : now = DateTime.now();

  final String nodeId;
  final DateTime now;

  @override
  List<Object?> get props => [nodeId, now];
}

// post data fetched for instant messaging
class UserActionNodeDataFetchedState extends UserActionState {
  UserActionNodeDataFetchedState({
    required this.nodeId,
    required this.success,
  }) : now = DateTime.now();

  final String nodeId;
  final DateTime now;
  final bool success;

  @override
  List<Object?> get props => [nodeId, now, success];
}

// comment data fetched for streaming
class UserActionCommentDataFetchedState extends UserActionState {
  UserActionCommentDataFetchedState({
    required this.commentId,
    required this.success,
  }) : now = DateTime.now();

  final String commentId;
  final DateTime now;
  final bool success;

  @override
  List<Object?> get props => [commentId, now, success];
}

/// node highlight state
class UserActionNodeHighlightState extends UserActionState {
  UserActionNodeHighlightState({
    required this.nodeId,
  }) : now = DateTime.now();

  final String nodeId;
  final DateTime now;

  @override
  List<Object?> get props => [nodeId, now];
}

class UserActionVoteResponse extends UserActionState {
  UserActionVoteResponse({
    required this.pollId,
  }) : now = DateTime.now();

  final String pollId;
  final DateTime now;

  @override
  List<Object?> get props => [pollId, now];
}

class UserActionVoteAddSuccessState extends UserActionVoteResponse {
  UserActionVoteAddSuccessState({
    required super.pollId,
    required this.commentCount,
    required this.likeCount,
    required this.options,
  });

  final int likeCount;
  final int commentCount;
  final List<OptionEntity> options;

  @override
  List<Object?> get props => [pollId, now, likeCount, commentCount, options];
}

class UserActionVoteAddFailureState extends UserActionVoteResponse {
  UserActionVoteAddFailureState({
    required super.pollId,
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [pollId, now, message];
}
