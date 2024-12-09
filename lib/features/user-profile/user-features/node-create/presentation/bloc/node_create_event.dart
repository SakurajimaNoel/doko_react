part of 'node_create_bloc.dart';

@immutable
sealed class NodeCreateEvent {}

class PostCreateEvent extends NodeCreateEvent {
  PostCreateEvent({
    required this.postDetails,
  });

  final PostCreateInput postDetails;
}
