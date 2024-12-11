part of 'node_create_bloc.dart';

@immutable
sealed class NodeCreateEvent {}

class PostCreateEvent extends NodeCreateEvent {
  PostCreateEvent({
    required this.postDetails,
  });

  final PostCreateInput postDetails;
}

class CreateCommentEvent extends NodeCreateEvent {
  CreateCommentEvent({
    required this.commentDetails,
  });

  final CommentCreateInput commentDetails;
}
