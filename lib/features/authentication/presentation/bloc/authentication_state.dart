part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState extends Equatable {}

final class AuthenticationInitial extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

final class AuthenticationLoading extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

final class AuthenticationError extends AuthenticationState {
  AuthenticationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AuthenticationSuccess extends AuthenticationState {
  AuthenticationSuccess({required this.status});

  final LoginStatus status;

  @override
  List<Object?> get props => [status];
}
