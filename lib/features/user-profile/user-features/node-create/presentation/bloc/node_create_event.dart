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
    required this.client,
    required this.remotePayload,
  });

  final CommentCreateInput commentDetails;
  final Client? client;
  final UserCreateSecondaryNode remotePayload;
}

class DiscussionCreateEvent extends NodeCreateEvent {
  DiscussionCreateEvent({
    required this.discussionDetails,
  });

  final DiscussionCreateInput discussionDetails;
}
