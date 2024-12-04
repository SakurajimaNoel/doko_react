part of 'user_action_bloc.dart';

@immutable
sealed class UserActionEvent {}

final class UserActionUpdateEvent extends UserActionEvent {
  UserActionUpdateEvent({
    required this.name,
    required this.bio,
    required this.profilePicture,
  });

  final String name;
  final String bio;
  final String profilePicture;
}
