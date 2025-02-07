part of 'root_node_bloc.dart';

@immutable
sealed class RootNodeState extends Equatable {}

final class RootNodeInitial extends RootNodeState {
  @override
  List<Object?> get props => [];
}

// when post is not present
final class RootNodeLoading extends RootNodeInitial {
  @override
  List<Object?> get props => [];
}

// when post is present
final class CommentLoadingState extends RootNodeInitial {
  @override
  List<Object?> get props => [];
}

// when either initial comments or post is loaded
final class PostAndCommentSuccessState extends RootNodeInitial {
  @override
  List<Object?> get props => [];
}

/// used when post is already present but
/// we don't need to fire it
final class PostSuccessState extends RootNodeInitial {
  @override
  List<Object?> get props => [];
}

final class CommentLoadSuccess extends RootNodeState {
  CommentLoadSuccess({
    required this.loadedCommentCount,
  });

  final int loadedCommentCount;

  @override
  List<Object?> get props => [loadedCommentCount];
}

// base class for comment replies loading
final class CommentReplyState extends RootNodeState {
  CommentReplyState({
    required this.commentId,
  });

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

final class CommentReplyLoadingState extends CommentReplyState {
  CommentReplyLoadingState({
    required super.commentId,
  });

  @override
  List<Object?> get props => [];
}

final class CommentReplyLoadSuccess extends CommentReplyState {
  CommentReplyLoadSuccess({
    required super.commentId,
    required this.loadedReplyCount,
  });

  final int loadedReplyCount;

  @override
  List<Object?> get props => [loadedReplyCount];
}

final class RootNodeErrorState extends RootNodeState {
  RootNodeErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CommentErrorState extends RootNodeState {
  CommentErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

// used with load more comments and comment replies
final class LoadErrorState extends RootNodeState {
  LoadErrorState({
    required this.message,
    required this.nodeId,
  });

  final String message;
  final String nodeId;

  @override
  List<Object?> get props => [message, nodeId];
}

// post refresh
final class PostRefreshState extends RootNodeState {
  @override
  List<Object?> get props => [];
}

final class PostRefreshSuccessState extends RootNodeInitial {
  PostRefreshSuccessState() : now = DateTime.now();

  final DateTime now;

  @override
  List<Object?> get props => [now];
}

final class PostRefreshErrorState extends RootNodeInitial {
  PostRefreshErrorState({
    required this.message,
  }) : now = DateTime.now();

  final String message;
  final DateTime now;

  @override
  List<Object?> get props => [message, now];
}
