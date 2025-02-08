part of 'root_node_bloc.dart';

/// primary node are nodes whose page we are on
/// like post, comment, discussion or more type added later
/// secondary nodes are always comment nodes but can have different meanings
/// like post secondary node is comment and comment secondary node is reply(technically it is comment node only in graph)

@immutable
sealed class RootNodeState extends Equatable {}

/// base class for all the state used in individual pages of the primary nodes
final class RootNodeInitial extends RootNodeState {
  @override
  List<Object?> get props => [];
}

/// when primary node is also not present like when deep linking to any primary node
final class RootNodeLoading extends RootNodeInitial {
  @override
  List<Object?> get props => [];
}

/// when primary node is already present (like post, discussion, comment)
final class SecondaryLoadingState extends RootNodeInitial {
  @override
  List<Object?> get props => [];
}

/// used when either complete primary node is available or secondary nodes are available
final class PrimaryAndSecondaryNodeSuccessState extends RootNodeInitial {
  @override
  List<Object?> get props => [];
}

/// used with infinite loading of replies
final class SecondaryLoadSuccess extends RootNodeState {
  SecondaryLoadSuccess({
    required this.loadedCommentCount,
  });

  final int loadedCommentCount;

  @override
  List<Object?> get props => [loadedCommentCount];
}

final class RootNodeErrorState extends RootNodeState {
  RootNodeErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class SecondaryNodeErrorState extends RootNodeState {
  SecondaryNodeErrorState({
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

/// primary node refresh states
final class PrimaryNodeRefreshSuccessState extends RootNodeInitial {
  PrimaryNodeRefreshSuccessState() : now = DateTime.now();

  final DateTime now;

  @override
  List<Object?> get props => [now];
}

final class PrimaryNodeRefreshErrorState extends RootNodeInitial {
  PrimaryNodeRefreshErrorState({
    required this.message,
  }) : now = DateTime.now();

  final String message;
  final DateTime now;

  @override
  List<Object?> get props => [message, now];
}
