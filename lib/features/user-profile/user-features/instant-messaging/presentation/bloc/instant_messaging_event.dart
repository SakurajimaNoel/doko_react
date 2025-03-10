part of 'instant_messaging_bloc.dart';

sealed class InstantMessagingEvent {
  const InstantMessagingEvent();
}

/// used with sending individual message
class InstantMessagingSendNewMessageEvent extends InstantMessagingEvent {
  const InstantMessagingSendNewMessageEvent({
    required this.message,
    required this.client,
    required this.username,
  });

  final ChatMessage message;
  final Client? client;
  final String username;
}

class InstantMessagingSendMultipleMessageEvent extends InstantMessagingEvent {
  const InstantMessagingSendMultipleMessageEvent({
    required this.messages,
    required this.client,
    required this.username,
  });

  final List<ChatMessage> messages;
  final Client? client;
  final String username;
}

class InstantMessagingEditMessageEvent extends InstantMessagingEvent {
  const InstantMessagingEditMessageEvent({
    required this.message,
    required this.client,
    required this.username,
  });

  final EditMessage message;
  final Client? client;
  final String username;
}

class InstantMessagingDeleteMessageEvent extends InstantMessagingEvent {
  const InstantMessagingDeleteMessageEvent({
    required this.message,
    required this.client,
    required this.username,
  });

  final DeleteMessage message;
  final Client? client;
  final String username;
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

/// delete inbox entry
class InstantMessagingDeleteInboxEntry extends InstantMessagingEvent {
  const InstantMessagingDeleteInboxEntry({
    required this.user,
    required this.inboxUser,
  });

  final String user;
  final String inboxUser;
}
