part of 'root_node_bloc.dart';

@immutable
sealed class RootNodeEvent {}

class PostLoadEvent extends RootNodeEvent {
  PostLoadEvent({
    required this.details,
  });

  final GetNodeInput details;
}

class CommentLoadEvent extends RootNodeEvent {
  CommentLoadEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class LoadMoreCommentEvent extends RootNodeEvent {
  LoadMoreCommentEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class LoadCommentReplyEvent extends RootNodeEvent {
  LoadCommentReplyEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class PostRefreshEvent extends RootNodeEvent {
  PostRefreshEvent({required this.details});

  final GetNodeInput details;
}
