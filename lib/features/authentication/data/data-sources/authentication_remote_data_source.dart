import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/authentication/data/models/setup_mfa/setup_mfa_model.dart';
import 'package:doko_react/features/authentication/domain/entities/login/login_entity.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';

class AuthenticationRemoteDataSource {
  const AuthenticationRemoteDataSource({
    required AuthCategory auth,
  }) : _auth = auth;

  final AuthCategory _auth;

  Future<LoginStatus> loginUser(LoginInput loginDetails) async {
    try {
      final result = await _auth.signIn(
        username: loginDetails.email,
        password: loginDetails.password,
      );

      return _handleLoginResult(
        result,
        loginDetails.email,
      );
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  LoginStatus _handleLoginResult(SignInResult result, String email) {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithTotpMfaCode:
        return LoginStatus.confirmMfa;
      case AuthSignInStep.done:
        return LoginStatus.done;
      case AuthSignInStep.confirmSignUp:
        // handle sending user confirm mail
        _auth.resendSignUpCode(
          username: email,
        );
        return LoginStatus.confirmSingUp;
      default:
        return LoginStatus.done;
    }
  }

  Future<LoginStatus> confirmLoginUser(String code) async {
    try {
      await _auth.confirmSignIn(confirmationValue: code);

      return LoginStatus.done;
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> signupUser(SignupInput signupDetails) async {
    try {
      await _auth.signUp(
        username: signupDetails.email,
        password: signupDetails.password,
      );

      return true;
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    final result = await _auth.signOut();

    if (result is CognitoFailedSignOut) {
      throw (result.exception.message);
    }
  }

  Future<bool> resetPassword(ResetPasswordInput resetDetails) async {
    try {
      await _auth.resetPassword(
        username: resetDetails.email,
      );

      return true;
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> confirmResetPassword(
      ConfirmResetPasswordInput resetDetails) async {
    try {
      await _auth.confirmResetPassword(
        username: resetDetails.email,
        confirmationCode: resetDetails.code,
        newPassword: resetDetails.password,
      );

      return true;
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> updatePassword(UpdatePasswordInput updatePasswordDetails) async {
    try {
      await _auth.updatePassword(
        oldPassword: updatePasswordDetails.oldPassword,
        newPassword: updatePasswordDetails.newPassword,
      );

      return true;
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<SetupMFAModel> setupMFA(String username) async {
    try {
      final totpSetupDetails = await _auth.setUpTotp();
      final setupUri = totpSetupDetails.getSetupUri(
        appName: 'Doki',
        accountName: username,
      );

      return SetupMFAModel(
        setupUri: setupUri,
        sharedSecret: totpSetupDetails.sharedSecret,
      );
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> verifyMFASetup(String code) async {
    try {
      await _auth.verifyTotpSetup(code);
      final cognitoPlugin = _auth.getPlugin(AmplifyAuthCognito.pluginKey);

      await cognitoPlugin.updateMfaPreference(
        totp: MfaPreference.preferred,
      );

      return true;
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> removeMFA() async {
    try {
      final cognitoPlugin = _auth.getPlugin(AmplifyAuthCognito.pluginKey);

      await cognitoPlugin.updateMfaPreference(
        totp: MfaPreference.disabled,
      );
    } on AuthException catch (e) {
      throw ApplicationException(reason: e.message);
    } catch (_) {
      rethrow;
    }
  }
}
