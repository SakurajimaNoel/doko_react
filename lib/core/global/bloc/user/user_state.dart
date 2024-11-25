part of 'user_bloc.dart';

@immutable
sealed class UserState extends Equatable {}

final class UserLoadingState extends UserState {
  @override
  List<Object?> get props => [];
}

final class UserUnauthenticatedState extends UserState {
  @override
  List<Object?> get props => [];
}

final class UserIncompleteState extends UserState {
  UserIncompleteState({
    required this.id,
    required this.email,
  });

  final String id;
  final String email;

  @override
  List<Object?> get props => [id, email];
}

final class UserCompleteState extends UserState {
  UserCompleteState({
    required this.id,
    required this.email,
    required this.username,
    required this.userMfa,
  });

  final String id;
  final String email;
  final String username;
  final bool userMfa;

  @override
  List<Object?> get props => [id, email, username, userMfa];

  UserCompleteState updateMFA(bool mfa) {
    return UserCompleteState(
      id: id,
      email: email,
      username: username,
      userMfa: mfa,
    );
  }
}

final class UserAuthErrorState extends UserState {
  @override
  List<Object?> get props => [];
}

final class UserGraphErrorState extends UserState {
  @override
  List<Object?> get props => [];
}
