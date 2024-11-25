part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

final class UserInitEvent extends UserEvent {}

final class UserAuthenticatedEvent extends UserEvent {}

final class UserSignOutEvent extends UserEvent {}

final class UserProfileCompleteEvent extends UserEvent {
  UserProfileCompleteEvent({
    required this.username,
    required this.userId,
    required this.email,
  });

  final String username;
  final String userId;
  final String email;
}

final class UserUpdateMFAEvent extends UserEvent {
  UserUpdateMFAEvent({required this.mfaStatus});

  final bool mfaStatus;
}
