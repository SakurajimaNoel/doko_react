import 'package:doko_react/features/authentication/data/data-sources/authentication_remote_data_source.dart';
import 'package:doko_react/features/authentication/domain/entities/login/login_entity.dart';
import 'package:doko_react/features/authentication/domain/entities/setup_mfa/setup_mfa_entity.dart';
import 'package:doko_react/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  const AuthenticationRepositoryImpl({required authenticationRemoteDataSource})
      : _remoteDataSource = authenticationRemoteDataSource;

  final AuthenticationRemoteDataSource _remoteDataSource;

  @override
  Future<LoginStatus> login(LoginInput loginDetails) {
    return _remoteDataSource.loginUser(loginDetails);
  }

  @override
  Future<LoginStatus> confirmLogin(String code) {
    return _remoteDataSource.confirmLoginUser(code);
  }

  @override
  Future<bool> signUp(SignupInput signupDetails) {
    return _remoteDataSource.signupUser(signupDetails);
  }

  @override
  Future<void> logOut() async {
    _remoteDataSource.logoutUser();
  }

  @override
  Future<bool> resetPassword(ResetPasswordInput resetPasswordDetails) {
    return _remoteDataSource.resetPassword(resetPasswordDetails);
  }

  @override
  Future<bool> confirmResetPassword(
      ConfirmResetPasswordInput confirmResetPasswordDetails) {
    return _remoteDataSource.confirmResetPassword(confirmResetPasswordDetails);
  }

  @override
  Future<bool> updatePassword(UpdatePasswordInput updatePasswordDetails) {
    return _remoteDataSource.updatePassword(updatePasswordDetails);
  }

  @override
  Future<SetupMFAEntity> setupMFA(String email) async {
    final result = await _remoteDataSource.setupMFA(email);
    return result.toEntity();
  }

  @override
  Future<bool> verifyMFASetup(String code) {
    return _remoteDataSource.verifyMFASetup(code);
  }

  @override
  Future<void> removeMFA() {
    return _remoteDataSource.removeMFA();
  }
}
