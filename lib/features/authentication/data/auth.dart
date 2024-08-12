import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

enum AuthStatus { done, confirmMFA, error }

class AuthenticationStatus {
  final AuthStatus status;
  final String? message;

  AuthenticationStatus({required this.status, this.message});
}

class AuthenticationActions {
  static Future<AuthenticationStatus> signInUser(
      String email, String password) async {
    try {
      final result =
          await Amplify.Auth.signIn(username: email, password: password);

      return _handleSignInResult(result, email);
    } on AuthException catch (e) {
      return AuthenticationStatus(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationStatus(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static Future<AuthenticationStatus> confirmSignInUser(
      String confirmString) async {
    try {
      await Amplify.Auth.confirmSignIn(confirmationValue: confirmString);

      return AuthenticationStatus(status: AuthStatus.done);
    } on AuthException catch (e) {
      return AuthenticationStatus(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationStatus(
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

  static Future<AuthenticationStatus> signUpUser(
      String email, String password) async {
    try {
      final result =
          await Amplify.Auth.signUp(username: email, password: password);


      return AuthenticationStatus(status: AuthStatus.done);
    } on AuthException catch (e) {
      return AuthenticationStatus(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationStatus(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static AuthenticationStatus _handleSignInResult(
      SignInResult result, String username) {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithTotpMfaCode:
        return AuthenticationStatus(status: AuthStatus.confirmMFA);
      case AuthSignInStep.done:
        return AuthenticationStatus(status: AuthStatus.done);
      case AuthSignInStep.confirmSignUp:
        // handle sending user confirm mail
        Amplify.Auth.resendSignUpCode(username: username);
        return AuthenticationStatus(
            status: AuthStatus.error,
            message:
                "Your account is not verified. Please verify it to proceed.");
      default:
        return AuthenticationStatus(status: AuthStatus.done);
    }
  }
}
