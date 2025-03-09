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

class InstantMessagingSendMultipleMessageEvent extends InstantMessagingEvent {
  const InstantMessagingSendMultipleMessageEvent({
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

class InstantMessagingDeleteMessageEvent extends InstantMessagingEvent {
  const InstantMessagingDeleteMessageEvent({
    required this.message,
    required this.client,
  });

  final DeleteMessage message;
  final Client? client;
}

/// querying user inbox and archives
class InstantMessagingGetUserInbox extends InstantMessagingEvent {
  const InstantMessagingGetUserInbox({
    required this.details,
  });

  final InboxQueryInput details;
}

class InstantMessagingGetUserArchive extends InstantMessagingEvent {
  const InstantMessagingGetUserArchive({
    required this.details,
  });

  final ArchiveQueryInput details;
}
