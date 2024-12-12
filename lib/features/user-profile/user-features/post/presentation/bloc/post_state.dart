part of 'post_bloc.dart';

@immutable
sealed class PostState extends Equatable {}

final class PostInitial extends PostState {
  @override
  List<Object?> get props => [];
}

// when post is not present
final class PostLoadingState extends PostInitial {
  @override
  List<Object?> get props => [];
}

// when post is present
final class CommentLoadingState extends PostInitial {
  @override
  List<Object?> get props => [];
}

// when either initial comments or post is loaded
final class PostAndCommentSuccessState extends PostInitial {
  @override
  List<Object?> get props => [];
}

/// used when post is already present but
/// we don't need to fire it
final class PostSuccessState extends PostInitial {
  @override
  List<Object?> get props => [];
}

final class CommentLoadSuccess extends PostState {
  CommentLoadSuccess({
    required this.loadedCommentCount,
  });

  final int loadedCommentCount;

  @override
  List<Object?> get props => [loadedCommentCount];
}

final class CommentReplyState extends PostState {
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

final class PostErrorState extends PostState {
  PostErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CommentErrorState extends PostState {
  CommentErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

// used with load more comments and comment replies
final class LoadErrorState extends PostState {
  LoadErrorState({
    required this.message,
    required this.nodeId,
  });

  final String message;
  final String nodeId;

  @override
  List<Object?> get props => [message, nodeId];
}

// comment search
final class CommentSearchState extends PostState {
  @override
  List<Object?> get props => [];
}

final class CommentSearchLoading extends CommentSearchState {
  @override
  List<Object?> get props => [];
}

final class CommentSearchSuccessState extends CommentSearchState {
  CommentSearchSuccessState({
    required this.searchResults,
  });

  final List<String> searchResults;

  @override
  List<Object?> get props => [searchResults];
}

final class CommentSearchErrorState extends PostState {
  CommentSearchErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

// post refresh
final class PostRefreshState extends PostState {
  @override
  List<Object?> get props => [];
}

final class PostRefreshSuccessState extends PostInitial {
  PostRefreshSuccessState() : now = DateTime.now();

  final DateTime now;

  @override
  List<Object?> get props => [now];
}

final class PostRefreshErrorState extends PostInitial {
  PostRefreshErrorState({
    required this.message,
  }) : now = DateTime.now();

  final String message;
  final DateTime now;

  @override
  List<Object?> get props => [message, now];
}
