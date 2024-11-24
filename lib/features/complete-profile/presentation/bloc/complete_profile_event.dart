part of 'complete_profile_bloc.dart';

@immutable
sealed class CompleteProfileEvent {}

final class CompleteProfileUsernameEvent extends CompleteProfileEvent {
  CompleteProfileUsernameEvent({
    required this.usernameInput,
  });

  final UsernameInput usernameInput;
}
