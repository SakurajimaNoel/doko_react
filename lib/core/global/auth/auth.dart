import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/token/token_entity.dart';

Future<AuthUser> getUser() async {
  try {
    return await Amplify.Auth.getCurrentUser();
  } on AuthException catch (e) {
    throw ApplicationException(reason: e.message);
  } catch (_) {
    rethrow;
  }
}

Future<String> getUsername() async {
  try {
    final result = await Amplify.Auth.fetchUserAttributes();
    String? username = result.singleWhere(
        (attribute) =>
            attribute.userAttributeKey ==
            AuthUserAttributeKey.preferredUsername, orElse: () {
      return AuthUserAttribute(
        userAttributeKey: AuthUserAttributeKey.preferredUsername,
        value: "",
      );
    }).value;
    return username;
  } on AuthException catch (_) {
    return "";
  } catch (_) {
    return "";
  }
}

// used to update user attribute of users
Future<bool> addUsername(String username) async {
  try {
    await Amplify.Auth.updateUserAttribute(
      userAttributeKey: AuthUserAttributeKey.preferredUsername,
      value: username,
    );
    return true;
  } on AuthException catch (_) {
    return false;
  } catch (_) {
    return false;
  }
}

Future<void> refreshAuthSession() async {
  try {
    await Amplify.Auth.fetchAuthSession(
      options: FetchAuthSessionOptions(
        forceRefresh: true,
      ),
    );
  } on AuthException catch (_) {
    return;
  } catch (_) {
    return;
  }
}

Future<TokenEntity> getUserToken() async {
  try {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final result = await cognitoPlugin.fetchAuthSession();

    String accessToken = (result.userPoolTokensResult.value.accessToken.raw);
    String idToken = (result.userPoolTokensResult.value.idToken.raw);

    return TokenEntity(
      accessToken: accessToken,
      idToken: idToken,
    );
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
