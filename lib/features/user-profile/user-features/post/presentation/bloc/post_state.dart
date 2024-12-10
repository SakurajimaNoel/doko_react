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

final class CommentReplyLoadSuccess extends PostState {
  CommentReplyLoadSuccess({
    required this.commentId,
    required this.loadedReplyCount,
  });

  final String commentId;
  final int loadedReplyCount;

  @override
  List<Object?> get props => [commentId, loadedReplyCount];
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
  });

  final String message;

  @override
  List<Object?> get props => [message];
}
