part of 'complete_profile_bloc.dart';

@immutable
sealed class CompleteProfileState extends Equatable {}

final class CompleteProfileInitialState extends CompleteProfileState {
  @override
  List<Object?> get props => [];
}

final class CompleteProfileLoadingState extends CompleteProfileState {
  @override
  List<Object?> get props => [];
}

final class CompleteProfileUsernameStatusState extends CompleteProfileState {
  CompleteProfileUsernameStatusState({
    required this.available,
    required this.username,
  });

  final bool available;
  final String username;

  String createDisplayMessage() {
    String message = "'$username' is ";
    if (!available) {
      message += "not ";
    }
    message += "available.";

    return message;
  }

  @override
  List<Object?> get props => [available, username];
}

final class CompleteProfileErrorState extends CompleteProfileState {
  CompleteProfileErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CompleteProfileCompletedState extends CompleteProfileState {
  @override
  List<Object?> get props => [];
}
