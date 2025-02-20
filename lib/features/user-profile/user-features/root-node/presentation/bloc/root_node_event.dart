part of 'root_node_bloc.dart';

@immutable
sealed class RootNodeEvent {}

/// load event used in individual pages
class PostLoadEvent extends RootNodeEvent {
  PostLoadEvent({
    required this.details,
  });

  final GetNodeInput details;
}

class CommentLoadEvent extends RootNodeEvent {
  CommentLoadEvent({
    required this.details,
    required this.fetchReply,
  });

  final GetNodeInput details;
  final bool fetchReply;
}

class DiscussionLoadEvent extends RootNodeEvent {
  DiscussionLoadEvent({
    required this.details,
  });

  final GetNodeInput details;
}

class PollLoadEvent extends RootNodeEvent {
  PollLoadEvent({
    required this.details,
  });

  final GetNodeInput details;
}

/// secondary nodes load event used when initially fetching the nodes
class SecondaryNodeLoadEvent extends RootNodeEvent {
  SecondaryNodeLoadEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class LoadMoreSecondaryNodesEvent extends RootNodeEvent {
  LoadMoreSecondaryNodesEvent({
    required this.details,
  });

  final GetCommentsInput details;
}

class PostRefreshEvent extends RootNodeEvent {
  PostRefreshEvent({required this.details});

  final GetNodeInput details;
}

class CommentRefreshEvent extends RootNodeEvent {
  CommentRefreshEvent({required this.details});

  final GetNodeInput details;
}

class DiscussionRefreshEvent extends RootNodeEvent {
  DiscussionRefreshEvent({required this.details});

  final GetNodeInput details;
}

class PollRefreshEvent extends RootNodeEvent {
  PollRefreshEvent({required this.details});

  final GetNodeInput details;
}
