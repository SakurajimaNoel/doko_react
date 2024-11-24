part of 'complete_profile_bloc.dart';

@immutable
sealed class CompleteProfileEvent {}

final class CompleteProfileUsernameEvent extends CompleteProfileEvent {
  CompleteProfileUsernameEvent({
    required this.usernameInput,
  });

  final UsernameInput usernameInput;
}

final class CompleteProfileDetailsEvent extends CompleteProfileEvent {
  CompleteProfileDetailsEvent({
    required this.completeUserDetails,
  });

  final CompleteProfileInput completeUserDetails;
}
