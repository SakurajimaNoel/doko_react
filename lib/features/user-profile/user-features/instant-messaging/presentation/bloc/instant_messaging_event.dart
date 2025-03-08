part of 'instant_messaging_bloc.dart';

sealed class InstantMessagingEvent {
  const InstantMessagingEvent();
}

/// used with sending individual message
class InstantMessagingSendNewMessageEvent extends InstantMessagingEvent {
  const InstantMessagingSendNewMessageEvent({
    required this.message,
    required this.client,
  });

  final ChatMessage message;
  final Client? client;
}

class InstantMessagingSendNewMessageToMultipleUserEvent
    extends InstantMessagingEvent {
  const InstantMessagingSendNewMessageToMultipleUserEvent({
    required this.messages,
    required this.client,
  });

  final List<ChatMessage> messages;
  final Client? client;
}

class InstantMessagingEditMessageEvent extends InstantMessagingEvent {
  const InstantMessagingEditMessageEvent({
    required this.message,
    required this.client,
  });

  final EditMessage message;
  final Client? client;
}

/// used with deleting for everyone
class InstantMessagingDeleteMessageEvent extends InstantMessagingEvent {
  const InstantMessagingDeleteMessageEvent({
    required this.message,
    required this.client,
  });

  final DeleteMessage message;
  final Client? client;
}
