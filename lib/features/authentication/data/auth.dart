import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

enum AuthStatus { done, confirmMFA, error }

class AuthenticationResult {
  final AuthStatus status;
  final String? message;

  AuthenticationResult({required this.status, this.message});
}

class AuthenticationActions {
  static Future<AuthenticationResult> signInUser(
      String email, String password) async {
    try {
      final result =
          await Amplify.Auth.signIn(username: email, password: password);

      return _handleSignInResult(result, email);
    } on AuthException catch (e) {
      return AuthenticationResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static Future<AuthenticationResult> confirmSignInUser(
      String confirmString) async {
    try {
      await Amplify.Auth.confirmSignIn(confirmationValue: confirmString);

      return AuthenticationResult(status: AuthStatus.done);
    } on AuthException catch (e) {
      return AuthenticationResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static Future<void> signOutUser() async {
    final result = await Amplify.Auth.signOut();

    if (result is CognitoCompleteSignOut) {
      safePrint("user signed out");
    } else if (result is CognitoFailedSignOut) {
      safePrint("error signing out user: ${result.exception.message}");
    }
  }

  static Future<AuthenticationResult> signUpUser(
      String email, String password) async {
    try {
      await Amplify.Auth.signUp(username: email, password: password);

      return AuthenticationResult(status: AuthStatus.done);
    } on AuthException catch (e) {
      return AuthenticationResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static Future<AuthenticationResult> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(username: email);

      return AuthenticationResult(status: AuthStatus.done);
    } on AuthException catch (e) {
      return AuthenticationResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static Future<AuthenticationResult> confirmResetPassword(
      String email, String code, String password) async {
    try {
      await Amplify.Auth.confirmResetPassword(
          username: email, confirmationCode: code, newPassword: password);

      return AuthenticationResult(status: AuthStatus.done);
    } on AuthException catch (e) {
      return AuthenticationResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static AuthenticationResult _handleSignInResult(
      SignInResult result, String username) {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithTotpMfaCode:
        return AuthenticationResult(status: AuthStatus.confirmMFA);
      case AuthSignInStep.done:
        return AuthenticationResult(status: AuthStatus.done);
      case AuthSignInStep.confirmSignUp:
        // handle sending user confirm mail
        Amplify.Auth.resendSignUpCode(username: username);
        return AuthenticationResult(
            status: AuthStatus.error,
            message:
                "Your account is not verified. Please verify it to proceed.");
      default:
        return AuthenticationResult(status: AuthStatus.done);
    }
  }
}
