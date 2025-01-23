part of 'instant_messaging_bloc.dart';

sealed class InstantMessagingState extends Equatable {
  const InstantMessagingState();
}

final class InstantMessagingInitial extends InstantMessagingState {
  @override
  List<Object> get props => [];
}

final class InstantMessagingNewMessageState extends InstantMessagingState {
  const InstantMessagingNewMessageState({
    required this.id,
    required this.archiveUser,
  });

  final String id;
  final String archiveUser;

  @override
  List<Object?> get props => [id, archiveUser];
}

final class InstantMessagingTypingStatusState extends InstantMessagingState {
  InstantMessagingTypingStatusState({
    required this.archiveUser,
    required this.typing,
  });

  final String archiveUser;
  final bool typing;
  final DateTime statusAt = DateTime.now();

  @override
  List<Object?> get props => [archiveUser, statusAt, typing];
}

final class InstantMessagingEditMessageState extends InstantMessagingState {
  InstantMessagingEditMessageState({
    required this.id,
    required this.archiveUser,
  });

  final String id;
  final String archiveUser;
  final DateTime editedAt = DateTime.now();

  @override
  List<Object?> get props => [id, editedAt, archiveUser];
}

final class InstantMessagingDeleteMessageState extends InstantMessagingState {
  InstantMessagingDeleteMessageState({
    required this.id,
    required this.archiveUser,
  });

  final List<String> id;
  final String archiveUser;
  final DateTime editedAt = DateTime.now();

  @override
  List<Object?> get props => [id.toString(), editedAt, archiveUser];
}
