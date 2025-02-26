part of 'user_feed_bloc.dart';

sealed class UserFeedState extends Equatable {
  const UserFeedState();
}

final class UserFeedLoading extends UserFeedState {
  @override
  List<Object> get props => [];
}

final class UserFeedGetResponseState extends UserFeedState {
  UserFeedGetResponseState() : now = DateTime.now();

  final DateTime now;

  @override
  List<Object> get props => [now];
}

final class UserFeedGetResponseSuccessState extends UserFeedGetResponseState {
  @override
  List<Object> get props => [now];
}

final class UserFeedGetResponseErrorState extends UserFeedGetResponseState {
  UserFeedGetResponseErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object> get props => [now, message];
}
