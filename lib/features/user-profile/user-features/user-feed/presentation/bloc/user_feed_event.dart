part of 'user_feed_bloc.dart';

sealed class UserFeedEvent {
  const UserFeedEvent();
}

final class UserFeedGetEvent extends UserFeedEvent {
  const UserFeedGetEvent({
    required this.details,
  });

  final UserFeedInput details;
}
