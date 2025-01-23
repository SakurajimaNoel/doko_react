part of 'instant_messaging_bloc.dart';

@immutable
sealed class InstantMessagingEvent {}

final class InstantMessagingNewMessageEvent extends InstantMessagingEvent {
  InstantMessagingNewMessageEvent({
    required this.message,
    required this.username,
  });

  final String username;
  final ChatMessage message;
}

final class InstantMessagingTypingStatusEvent extends InstantMessagingEvent {
  InstantMessagingTypingStatusEvent({
    required this.status,
  });

  final TypingStatus status;
}

final class InstantMessagingEditMessageEvent extends InstantMessagingEvent {
  InstantMessagingEditMessageEvent({
    required this.message,
    required this.username,
  });

  final EditMessage message;
  final String username;
}

final class InstantMessagingDeleteMessageEvent extends InstantMessagingEvent {
  InstantMessagingDeleteMessageEvent({
    required this.message,
    required this.username,
  });

  final DeleteMessage message;
  final String username;
}
