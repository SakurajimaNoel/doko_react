
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class AuthenticationActions {
  static Future<void> signInUser(String email, String password) async {
    try {
      final result =
          await Amplify.Auth.signIn(username: email, password: password);

      safePrint(result);
    } on AuthException catch (e) {
      safePrint("error signing in: ${e.message}");
    } catch (e) {
      safePrint("other error: $e");
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
}
