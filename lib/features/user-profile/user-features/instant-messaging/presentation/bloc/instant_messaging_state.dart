part of 'instant_messaging_bloc.dart';

sealed class InstantMessagingState extends Equatable {
  const InstantMessagingState();
}

final class InstantMessagingInitial extends InstantMessagingState {
  @override
  List<Object> get props => [];
}

final class InstantMessagingSuccessState extends InstantMessagingState {
  InstantMessagingSuccessState() : now = DateTime.now();

  final DateTime now;

  @override
  List<Object> get props => [now];
}

final class InstantMessagingErrorState extends InstantMessagingState {
  InstantMessagingErrorState({
    required this.message,
  }) : now = DateTime.now();

  final DateTime now;
  final String message;

  @override
  List<Object> get props => [now, message];
}

/// message send states
final class InstantMessagingSendMessageToMultipleUserSuccessState
    extends InstantMessagingSuccessState {
  InstantMessagingSendMessageToMultipleUserSuccessState({
    required this.messages,
  });

  final List<ChatMessage> messages;
}

final class InstantMessagingSendMessageSuccessState
    extends InstantMessagingSuccessState {
  InstantMessagingSendMessageSuccessState({
    required this.message,
  });

  final ChatMessage message;
}

final class InstantMessagingSendMessageErrorState
    extends InstantMessagingErrorState {
  InstantMessagingSendMessageErrorState({
    required super.message,
  });

  @override
  List<Object> get props => [];
}

final class InstantMessagingSendMessageToMultipleUserErrorState
    extends InstantMessagingErrorState {
  InstantMessagingSendMessageToMultipleUserErrorState({
    required this.messagesSent,
    required super.message,
  });

  final List<ChatMessage> messagesSent;

  @override
  List<Object> get props => [messagesSent];
}

/// delete message state
final class InstantMessagingDeleteMessageSuccessState
    extends InstantMessagingSuccessState {
  InstantMessagingDeleteMessageSuccessState({
    required this.message,
  });

  final DeleteMessage message;

  @override
  List<Object> get props => [message];
}

final class InstantMessagingDeleteMessageErrorState
    extends InstantMessagingErrorState {
  InstantMessagingDeleteMessageErrorState({
    required super.message,
    required this.multiple,
  });

  final bool multiple;

  @override
  List<Object> get props => [];
}
