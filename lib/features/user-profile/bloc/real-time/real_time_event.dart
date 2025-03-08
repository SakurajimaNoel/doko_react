part of 'real_time_bloc.dart';

@immutable
sealed class RealTimeEvent {}

final class RealTimeNewMessageEvent extends RealTimeEvent {
  RealTimeNewMessageEvent({
    required this.message,
    required this.username,
    required this.client,
  });

  final String username;
  final ChatMessage message;
  final Client? client;
}

final class RealTimeTypingStatusEvent extends RealTimeEvent {
  RealTimeTypingStatusEvent({
    required this.status,
  });

  final TypingStatus status;
}

final class RealTimeTypingStatusEndEvent extends RealTimeEvent {
  RealTimeTypingStatusEndEvent({
    required this.username,
  });

  /// username of user whose typing status will expire
  final String username;
}

final class RealTimeEditMessageEvent extends RealTimeEvent {
  RealTimeEditMessageEvent({
    required this.message,
    required this.username,
    required this.client,
  });

  final EditMessage message;
  final String username;
  final Client? client;
}

final class RealTimeDeleteMessageEvent extends RealTimeEvent {
  RealTimeDeleteMessageEvent({
    required this.message,
    required this.username,
    required this.client,
  });

  final DeleteMessage message;
  final String username;
  final Client? client;
}

final class RealTimeUserPresenceEvent extends RealTimeEvent {
  RealTimeUserPresenceEvent({
    required this.payload,
  });

  final UserPresenceInfo payload;
}

/// mark inbox item as read
final class RealTimeMarkInboxAsReadEvent extends RealTimeEvent {
  RealTimeMarkInboxAsReadEvent({
    required this.username,
    required this.client,
  });

  final String username;
  final Client? client;
}
