part of 'instant_messaging_bloc.dart';

sealed class InstantMessagingEvent {
  const InstantMessagingEvent();
}

sealed class InstantMessagingSendNewMessageEvent extends InstantMessagingEvent {
  const InstantMessagingSendNewMessageEvent({
    required this.message,
    required this.client,
  });

  final ChatMessage message;
  final Client? client;
}

sealed class InstantMessagingEditMessageEvent extends InstantMessagingEvent {
  const InstantMessagingEditMessageEvent({
    required this.message,
    required this.client,
  });

  final EditMessage message;
  final Client? client;
}

sealed class InstantMessagingDeleteMessageEvent extends InstantMessagingEvent {
  const InstantMessagingDeleteMessageEvent({
    required this.message,
    required this.client,
  });

  final DeleteMessage message;
  final Client? client;
}
