part of 'post_bloc.dart';

@immutable
sealed class PostEvent {}

class PostLoadEvent extends PostEvent {
  PostLoadEvent({
    required this.details,
  });

  final GetPostInput details;
}

class CommentLoadEvent extends PostEvent {
  CommentLoadEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class LoadMoreCommentEvent extends PostEvent {
  LoadMoreCommentEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class LoadCommentReplyEvent extends PostEvent {
  LoadCommentReplyEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class CommentMentionSearchEvent extends PostEvent {
  CommentMentionSearchEvent({
    required this.searchDetails,
  });

  final UserSearchInput searchDetails;
}
