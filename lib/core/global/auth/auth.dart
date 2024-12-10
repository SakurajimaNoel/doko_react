import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';

Future<AuthUser> getUser() async {
  try {
    return await Amplify.Auth.getCurrentUser();
  } on AuthException catch (e) {
    throw ApplicationException(reason: e.message);
  } catch (_) {
    rethrow;
  }
}

Future<String> getAccessToken() async {
  try {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final result = await cognitoPlugin.fetchAuthSession();

    String token = (result.userPoolTokensResult.value.accessToken.raw);

    // Clipboard.setData(ClipboardData(text: token)).then((value) {});
    return token;
  } on AuthException catch (e) {
    throw ApplicationException(reason: e.message);
  } catch (_) {
    rethrow;
  }
}

/// returns true if setup otherwise false
Future<bool> getUserMFAStatus() async {
  try {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final currentPreference = await cognitoPlugin.fetchMfaPreference();

    return currentPreference.preferred != null;
  } on AuthException catch (e) {
    throw ApplicationException(reason: e.message);
  } catch (_) {
    rethrow;
  }
}
