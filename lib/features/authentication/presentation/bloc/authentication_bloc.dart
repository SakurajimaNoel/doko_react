import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/entities/login/login_entity.dart';
import 'package:doko_react/features/authentication/domain/entities/setup_mfa/setup_mfa_entity.dart';
import 'package:doko_react/features/authentication/domain/use-cases/login-use-case/confirm_login_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/login-use-case/login_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/logout-use-case/logout_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/mfa-use-case/remove_mfa_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/mfa-use-case/setup_mfa_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/mfa-use-case/verify_mfa_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/password-use-case/confirm_reset_password_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/password-use-case/reset_password_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/password-use-case/update_password_use_case.dart';
import 'package:doko_react/features/authentication/domain/use-cases/sign-up-use-case/sign_up_use_case.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUseCase _loginUseCase;
  final ConfirmLoginUseCase _confirmLoginUseCase;
  final SignUpUseCase _signUpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ConfirmResetPasswordUseCase _confirmResetPasswordUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final LogoutUseCase _logoutUseCase;
  final RemoveMFAUseCase _removeMFAUseCase;
  final SetupMFAUseCase _setupMFAUseCase;
  final VerifyMFAUseCase _verifyMFAUseCase;

  AuthenticationBloc({
    required LoginUseCase loginUseCase,
    required ConfirmLoginUseCase confirmLoginUseCase,
    required SignUpUseCase signUpUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required ConfirmResetPasswordUseCase confirmResetPasswordUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required LogoutUseCase logoutUseCase,
    required RemoveMFAUseCase removeMFAUseCase,
    required SetupMFAUseCase setupMFAUseCase,
    required VerifyMFAUseCase verifyMFAUseCase,
  })  : _loginUseCase = loginUseCase,
        _confirmLoginUseCase = confirmLoginUseCase,
        _signUpUseCase = signUpUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _confirmResetPasswordUseCase = confirmResetPasswordUseCase,
        _updatePasswordUseCase = updatePasswordUseCase,
        _logoutUseCase = logoutUseCase,
        _removeMFAUseCase = removeMFAUseCase,
        _setupMFAUseCase = setupMFAUseCase,
        _verifyMFAUseCase = verifyMFAUseCase,
        super(AuthenticationInitial()) {
    on<LoginEvent>(_handleLoginEvent);
    on<ConfirmLoginEvent>(_handleConfirmLoginEvent);
    on<SignupEvent>(_handleSignUpEvent);
    on<ResetPasswordEvent>(_handleResetPasswordEvent);
    on<ConfirmResetPasswordEvent>(_handleConfirmResetPasswordEvent);
    on<UpdatePasswordEvent>(_handleUpdatePasswordEvent);
    on<LogoutEvent>(_handleLogoutEvent);
    on<RemoveMFAEvent>(_handleRemoveMFAEvent);
    on<SetupMFAEvent>(_handleSetupMFAEvent);
    on<VerifyMFAEvent>(_handleVerifyMFAEvent);
  }

  FutureOr<void> _handleLoginEvent(
      LoginEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      final status = await _loginUseCase(event.loginDetails);
      emit(AuthenticationLoginSuccess(status: status));
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleConfirmLoginEvent(
      ConfirmLoginEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      final status = await _confirmLoginUseCase(event.code);

      emit(AuthenticationLoginSuccess(status: status));
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleSignUpEvent(
      SignupEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      await _signUpUseCase(event.signupDetails);
      emit(AuthenticationSignUpSuccess());
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleResetPasswordEvent(
      ResetPasswordEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      await _resetPasswordUseCase(event.resetDetails);
      emit(AuthenticationResetPasswordSuccess());
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleConfirmResetPasswordEvent(
      ConfirmResetPasswordEvent event,
      Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      await _confirmResetPasswordUseCase(event.resetDetails);
      emit(AuthenticationConfirmResetPasswordSuccess());
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleUpdatePasswordEvent(
      UpdatePasswordEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      await _updatePasswordUseCase(event.updateDetails);
      emit(AuthenticationUpdatePasswordSuccess());
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleLogoutEvent(
      LogoutEvent event, Emitter<AuthenticationState> emit) async {
    try {
      await _logoutUseCase(NoParams());
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleRemoveMFAEvent(
      RemoveMFAEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      await _removeMFAUseCase(NoParams());
      emit(AuthenticationRemoveMFASuccess());
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleSetupMFAEvent(
      SetupMFAEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      var setupData = await _setupMFAUseCase(event.username);
      emit(AuthenticationMFASetupSuccess(setupData: setupData));

      if (await canLaunchUrl(setupData.setupUri)) {
        await launchUrl(setupData.setupUri);
      }
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleVerifyMFAEvent(
      VerifyMFAEvent event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationLoading());
      await _verifyMFAUseCase(event.code);
      emit(AuthenticationVerifyMFASuccess());
    } on ApplicationException catch (e) {
      emit(AuthenticationError(message: e.reason));
    } catch (_) {
      emit(AuthenticationError(
        message: Constants.errorMessage,
      ));
    }
  }
}
