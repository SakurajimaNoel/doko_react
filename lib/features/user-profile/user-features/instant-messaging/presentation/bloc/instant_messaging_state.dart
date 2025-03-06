part of 'instant_messaging_bloc.dart';

sealed class InstantMessagingState extends Equatable {
  const InstantMessagingState();
}

final class InstantMessagingInitial extends InstantMessagingState {
  @override
  List<Object> get props => [];
}

final class InstantMessagingSuccessState extends InstantMessagingState {
  const InstantMessagingSuccessState({
    required this.messageId,
    required this.now,
  });

  final List<String> messageId;
  final DateTime now;

  @override
  List<Object> get props => [messageId, now];
}

final class InstantMessagingErrorState extends InstantMessagingState {
  const InstantMessagingErrorState({
    required this.messageId,
    required this.now,
  });

  final List<String> messageId;
  final DateTime now;

  @override
  List<Object> get props => [messageId, now];
}
