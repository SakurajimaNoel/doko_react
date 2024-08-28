import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/services.dart';

enum AuthStatus { done, confirmMFA, error }

class AuthenticationResult {
  final AuthStatus status;
  final String? message;
  final Uri? url;

  AuthenticationResult({
    required this.status,
    this.message,
    this.url,
  });
}

class AuthenticationToken {
  final AuthStatus status;
  final String value;

  AuthenticationToken({
    required this.status,
    required this.value,
  });
}

class AuthenticationActions {
  static Future<AuthenticationResult> signInUser(
      String email, String password) async {
    try {
      final result =
          await Amplify.Auth.signIn(username: email, password: password);

      return _handleSignInResult(
        result,
        email,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
    }
  }

  static Future<AuthenticationResult> confirmSignInUser(
      String confirmString) async {
    try {
      await Amplify.Auth.confirmSignIn(confirmationValue: confirmString);

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
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

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
    }
  }

  static Future<AuthenticationResult> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(username: email);

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
    }
  }

  static Future<AuthenticationResult> confirmResetPassword(
      String email, String code, String password) async {
    try {
      await Amplify.Auth.confirmResetPassword(
          username: email, confirmationCode: code, newPassword: password);

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
    }
  }

  static AuthenticationResult _handleSignInResult(
      SignInResult result, String username) {
    switch (result.nextStep.signInStep) {
      case AuthSignInStep.confirmSignInWithTotpMfaCode:
        return AuthenticationResult(
          status: AuthStatus.confirmMFA,
        );
      case AuthSignInStep.done:
        return AuthenticationResult(
          status: AuthStatus.done,
        );
      case AuthSignInStep.confirmSignUp:
        // handle sending user confirm mail
        Amplify.Auth.resendSignUpCode(username: username);
        return AuthenticationResult(
          status: AuthStatus.error,
          message: "Your account is not verified. Please verify it to proceed.",
        );
      default:
        return AuthenticationResult(
          status: AuthStatus.done,
        );
    }
  }

  static Future<AuthenticationResult> setupMfa() async {
    try {
      final userAttributes = await Amplify.Auth.fetchUserAttributes();
      var email = userAttributes.firstWhere(
          (attribute) =>
              attribute.userAttributeKey == CognitoUserAttributeKey.email,
          orElse: () => const AuthUserAttribute(
              userAttributeKey: CognitoUserAttributeKey.email, value: "dokii"));

      final totpSetupDetails = await Amplify.Auth.setUpTotp();
      final setupUri = totpSetupDetails.getSetupUri(
          appName: 'Doki', accountName: email.value);

      return AuthenticationResult(
        status: AuthStatus.done,
        url: setupUri,
        message: totpSetupDetails.sharedSecret,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(status: AuthStatus.error, message: e.message);
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
          status: AuthStatus.error, message: "Oops! Something went wrong.");
    }
  }

  static Future<AuthenticationResult> verifyMfaSetup(String code) async {
    try {
      await Amplify.Auth.verifyTotpSetup(code);
      final cognitoPlugin =
          Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);

      await cognitoPlugin.updateMfaPreference(
        totp: MfaPreference.preferred,
      );

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
    }
  }

  static Future<void> removeMFA() async {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);

    await cognitoPlugin.updateMfaPreference(
      totp: MfaPreference.disabled,
    );
  }

  static Future<AuthenticationToken> getAccessToken() async {
    try {
      final cognitoPlugin =
          Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final result = await cognitoPlugin.fetchAuthSession();
      String token = (result.userPoolTokensResult.value.accessToken.raw);

      Clipboard.setData(ClipboardData(text: token)).then((value) {});
      return AuthenticationToken(
        status: AuthStatus.done,
        value: token,
      );
    } on AuthException catch (e) {
      return AuthenticationToken(
        status: AuthStatus.error,
        value: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationToken(
        status: AuthStatus.error,
        value: "Oops! Something went wrong.",
      );
    }
  }

  static Future<AuthenticationResult> updatePassword(
      String oldPassword, String newPassword) async {
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
    }
  }

  static Future<AuthenticationResult> getUserId() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return AuthenticationResult(
        status: AuthStatus.done,
        message: user.userId,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e);
      return AuthenticationResult(
        status: AuthStatus.error,
        message: "Oops! Something went wrong.",
      );
    }
  }
}
