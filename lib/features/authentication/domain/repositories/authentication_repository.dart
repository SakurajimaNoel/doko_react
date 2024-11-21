import 'package:doko_react/features/authentication/domain/entities/login/login_entity.dart';
import 'package:doko_react/features/authentication/domain/entities/setup_mfa/setup_mfa_entity.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';

abstract class AuthenticationRepository {
  Future<LoginStatus> login(LoginInput loginDetails);

  Future<LoginStatus> confirmLogin(String code);

  Future<bool> signUp(SignupInput signUpDetails);

  Future<void> logOut();

  Future<bool> resetPassword(ResetPasswordInput resetPasswordDetails);

  Future<bool> confirmResetPassword(
      ConfirmResetPasswordInput confirmResetPasswordDetails);

  /// authenticated user methods
  /// don't require checking for email validation
  Future<bool> updatePassword(UpdatePasswordInput updatePasswordDetails);

  Future<SetupMFAEntity> setupMFA(String email);

  Future<bool> verifyMFASetup(String code);

  Future<void> removeMFA();
}
