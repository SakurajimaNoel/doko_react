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
