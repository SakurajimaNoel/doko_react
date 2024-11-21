part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

final class LoginEvent extends AuthenticationEvent {
  LoginEvent({required this.loginDetails});

  final LoginInput loginDetails;
}

final class ConfirmLoginEvent extends AuthenticationEvent {
  ConfirmLoginEvent({required this.code});

  final String code;
}

final class SignupEvent extends AuthenticationEvent {
  SignupEvent({required this.signupDetails});

  final SignupInput signupDetails;
}

final class ResetPasswordEvent extends AuthenticationEvent {
  ResetPasswordEvent({required this.resetDetails});

  final ResetPasswordInput resetDetails;
}

final class ConfirmResetPassword extends AuthenticationEvent {
  ConfirmResetPassword({required this.resetDetails});

  final ConfirmResetPasswordInput resetDetails;
}

final class LogoutEvent extends AuthenticationEvent {}

final class UpdatePasswordEvent extends AuthenticationEvent {
  UpdatePasswordEvent({required this.updateDetails});

  final UpdatePasswordInput updateDetails;
}

final class SetupMFAEvent extends AuthenticationEvent {}

final class ConfirmMFAEvent extends AuthenticationEvent {
  ConfirmMFAEvent({required this.code});

  final String code;
}

final class RemoveMFAEvent extends AuthenticationEvent {}
