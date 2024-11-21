part of 'user_bloc.dart';

@immutable
sealed class UserState extends Equatable {}

final class UserLoading extends UserState {
  @override
  List<Object?> get props => [];
}

final class UserUnauthenticated extends UserState {
  @override
  List<Object?> get props => [];
}

final class UserIncomplete extends UserState {
  UserIncomplete({
    required this.id,
    required this.email,
  });

  final String id;
  final String email;

  @override
  List<Object?> get props => [id, email];
}

final class UserComplete extends UserState {
  UserComplete({
    required this.id,
    required this.email,
    required this.username,
    required this.userMfa,
  });

  final String id;
  final String email;
  final String username;
  final bool userMfa;

  /// don't want to refresh router when mfa status is changed
  /// storing mfa status as fetching it on settings page takes time
  /// so storing it during startup
  @override
  List<Object?> get props => [id, email, username];
}

final class UserAuthError extends UserState {
  @override
  List<Object?> get props => [];
}

final class UserGraphError extends UserState {
  @override
  List<Object?> get props => [];
}
