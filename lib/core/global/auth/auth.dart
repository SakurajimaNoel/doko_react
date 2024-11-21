import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/services.dart';

Future<AuthUser> getUser() async {
  try {
    return await Amplify.Auth.getCurrentUser();
  } catch (e) {
    rethrow;
  }
}

Future<String> getAccessToken() async {
  try {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final result = await cognitoPlugin.fetchAuthSession();

    String token = (result.userPoolTokensResult.value.accessToken.raw);

    Clipboard.setData(ClipboardData(text: token)).then((value) {});
    return token;
  } catch (e) {
    rethrow;
  }
}

/// returns true if setup otherwise false
Future<bool> getUserMFAStatus() async {
  final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
  final currentPreference = await cognitoPlugin.fetchMfaPreference();

  return currentPreference.preferred != null;
}
