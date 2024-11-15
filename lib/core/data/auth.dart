import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/helpers/constants.dart';

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
  final AuthCategory auth;

  // send auth = Amplify.Auth;
  AuthenticationActions({
    required this.auth,
  });

  Future<AuthenticationResult> signInUser(String email, String password) async {
    try {
      final result = await auth.signIn(username: email, password: password);

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
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<AuthenticationResult> confirmSignInUser(String confirmString) async {
    try {
      await auth.confirmSignIn(confirmationValue: confirmString);

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<void> signOutUser() async {
    final result = await auth.signOut();

    if (result is CognitoCompleteSignOut) {
      safePrint("user signed out");
    } else if (result is CognitoFailedSignOut) {
      safePrint("error signing out user: ${result.exception.message}");
    }
  }

  Future<AuthenticationResult> signUpUser(String email, String password) async {
    try {
      await auth.signUp(username: email, password: password);

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<AuthenticationResult> resetPassword(String email) async {
    try {
      await auth.resetPassword(username: email);

      return AuthenticationResult(
        status: AuthStatus.done,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<AuthenticationResult> confirmResetPassword(
      String email, String code, String password) async {
    try {
      await auth.confirmResetPassword(
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
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  AuthenticationResult _handleSignInResult(
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
        auth.resendSignUpCode(username: username);
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

  Future<AuthenticationResult> getEmail() async {
    try {
      final userAttributes = await auth.fetchUserAttributes();
      var email = userAttributes.firstWhere(
        (attribute) =>
            attribute.userAttributeKey == CognitoUserAttributeKey.email,
        orElse: () => const AuthUserAttribute(
          userAttributeKey: CognitoUserAttributeKey.email,
          value: "dokii",
        ),
      );

      return AuthenticationResult(
        status: AuthStatus.done,
        message: email.value,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<AuthenticationResult> setupMfa(String username) async {
    try {
      final totpSetupDetails = await auth.setUpTotp();
      final setupUri = totpSetupDetails.getSetupUri(
        appName: 'Doki',
        accountName: username,
      );

      return AuthenticationResult(
        status: AuthStatus.done,
        url: setupUri,
        message: totpSetupDetails.sharedSecret,
      );
    } on AuthException catch (e) {
      return AuthenticationResult(
        status: AuthStatus.error,
        message: e.message,
      );
    } catch (e) {
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<AuthenticationResult> verifyMfaSetup(String code) async {
    try {
      await auth.verifyTotpSetup(code);
      final cognitoPlugin = auth.getPlugin(AmplifyAuthCognito.pluginKey);

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
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<void> removeMFA() async {
    final cognitoPlugin = auth.getPlugin(AmplifyAuthCognito.pluginKey);

    await cognitoPlugin.updateMfaPreference(
      totp: MfaPreference.disabled,
    );
  }

  Future<AuthenticationToken> getAccessToken() async {
    try {
      final cognitoPlugin = auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final result = await cognitoPlugin.fetchAuthSession();

      String token = (result.userPoolTokensResult.value.accessToken.raw);

      // Clipboard.setData(ClipboardData(text: token)).then((value) {});
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
      safePrint(e.toString());
      return AuthenticationToken(
        status: AuthStatus.error,
        value: Constants.errorMessage,
      );
    }
  }

  Future<AuthenticationResult> updatePassword(
      String oldPassword, String newPassword) async {
    try {
      await auth.updatePassword(
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
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }

  Future<AuthenticationResult> getUserId() async {
    try {
      final user = await auth.getCurrentUser();
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
      safePrint(e.toString());
      return AuthenticationResult(
        status: AuthStatus.error,
        message: Constants.errorMessage,
      );
    }
  }
}
