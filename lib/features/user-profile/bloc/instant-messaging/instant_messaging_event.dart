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
