part of 'node_create_bloc.dart';

@immutable
sealed class NodeCreateState extends Equatable {}

final class NodeCreateInitial extends NodeCreateState {
  @override
  List<Object?> get props => [];
}

final class NodeCreateLoading extends NodeCreateState {
  @override
  List<Object?> get props => [];
}

final class NodeCreateSuccess extends NodeCreateState {
  NodeCreateSuccess({
    required this.nodeId,
  });

  final String nodeId;

  @override
  List<Object?> get props => [nodeId];
}

final class NodeCreateError extends NodeCreateState {
  NodeCreateError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}
