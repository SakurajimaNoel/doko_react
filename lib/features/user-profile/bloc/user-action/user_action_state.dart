part of 'user_action_bloc.dart';

@immutable
sealed class UserActionState extends Equatable {}

final class UserActionInitial extends UserActionState {
  @override
  List<Object?> get props => [];
}

// more post action
class UserActionLoadPosts extends UserActionState {
  UserActionLoadPosts({
    required this.loadedPostCount,
    required this.username,
  });

  final String username;
  final int loadedPostCount;

  @override
  List<Object?> get props => [username, loadedPostCount];
}

class UserActionNewPostState extends UserActionState {
  UserActionNewPostState({
    required this.postId,
    required this.username,
  });

  final String postId;
  final String username;

  @override
  List<Object?> get props => [postId, username];
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
class UserActionPostDataFetchedState extends UserActionState {
  UserActionPostDataFetchedState({
    required this.postId,
    required this.success,
  }) : now = DateTime.now();

  final String postId;
  final DateTime now;
  final bool success;

  @override
  List<Object?> get props => [postId, now, success];
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
