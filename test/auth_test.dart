import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthCategory extends Mock implements AuthCategory {}

class MockAmplifyAuthCognito extends Mock implements AmplifyAuthCognito {}

class MockCognitoAuthSession extends Mock implements CognitoAuthSession {}

class MockCognitoUserPoolTokens extends Mock implements CognitoUserPoolTokens {}

class MockJsonWebToken extends Mock implements JsonWebToken {}

void main() {
  late AuthCategory authCategory;
  late AmplifyAuthCognito amplifyAuthCognito;
  late MockCognitoAuthSession authSession;
  late MockCognitoUserPoolTokens cognitoUserPoolTokens;
  late AuthenticationActions auth;
  late AuthSuccessResult<CognitoUserPoolTokens> authSuccessResult;
  late MockJsonWebToken token;

  String email = "abc@gmail.com";
  String password = "abc@1234";
  String code = "123456";
  String authExceptionString = "auth exception";
  String accessToken = "access-token";
  String userId = "user-id";

  setUp(() {
    authCategory = MockAuthCategory();
    amplifyAuthCognito = MockAmplifyAuthCognito();
    authSession = MockCognitoAuthSession();
    cognitoUserPoolTokens = MockCognitoUserPoolTokens();
    authSuccessResult = AWSSuccessResult(cognitoUserPoolTokens);
    token = MockJsonWebToken();
    auth = AuthenticationActions(auth: authCategory);
  });

  group("authentication test - ", () {
    group("sign in - ", () {
      test("given email and password return success response", () async {
        // arrange
        when(
          () => authCategory.signIn(username: email, password: password),
        ).thenAnswer(
          (invocation) async {
            return const SignInResult(
              isSignedIn: true,
              nextStep: AuthNextSignInStep(
                signInStep: AuthSignInStep.done,
              ),
            );
          },
        );

        // act
        final result = await auth.signInUser(email, password);

        // assert
        expect(result.status, AuthStatus.done);
      });

      test("given email and password return success response with next step",
          () async {
        // arrange
        when(
          () => authCategory.signIn(username: email, password: password),
        ).thenAnswer(
          (invocation) async {
            return const SignInResult(
              isSignedIn: false,
              nextStep: AuthNextSignInStep(
                signInStep: AuthSignInStep.confirmSignInWithTotpMfaCode,
              ),
            );
          },
        );

        // act
        final result = await auth.signInUser(email, password);

        // assert
        expect(result.status, AuthStatus.confirmMFA);
      });

      test(
          "given email and password when user signup is not complete return error response with message",
          () async {
        // arrange
        when(
          () => authCategory.signIn(username: email, password: password),
        ).thenAnswer(
          (invocation) async {
            return const SignInResult(
              isSignedIn: false,
              nextStep: AuthNextSignInStep(
                signInStep: AuthSignInStep.confirmSignUp,
              ),
            );
          },
        );

        when(
          () => authCategory.resendSignUpCode(username: email),
        ).thenAnswer((invocation) async {
          return const ResendSignUpCodeResult(
            AuthCodeDeliveryDetails(
              deliveryMedium: DeliveryMedium.email,
            ),
          );
        });

        // act
        final result = await auth.signInUser(email, password);

        // assert
        expect(result.status, AuthStatus.error);
        expect(result.message,
            "Your account is not verified. Please verify it to proceed.");
      });

      test(
          "given email and password when auth exception occurs return error response with message",
          () async {
        // arrange
        when(
          () => authCategory.signIn(username: email, password: password),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        // act
        final result = await auth.signInUser(email, password);

        // assert
        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test(
          "given email and password when general exception occurs return error response with message",
          () async {
        // arrange
        when(
          () => authCategory.signIn(username: email, password: password),
        ).thenThrow(UnknownException);

        // act
        final result = await auth.signInUser(email, password);

        // assert
        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("confirm sign in - ", () {
      test("given confirm string return success response", () async {
        when(
          () => authCategory.confirmSignIn(
            confirmationValue: code,
          ),
        ).thenAnswer((invocation) async {
          return const SignInResult(
            isSignedIn: true,
            nextStep: AuthNextSignInStep(
              signInStep: AuthSignInStep.done,
            ),
          );
        });

        final result = await auth.confirmSignInUser(code);

        expect(result.status, AuthStatus.done);
      });

      test("given confirm string return error response", () async {
        when(
          () => authCategory.confirmSignIn(
            confirmationValue: code,
          ),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.confirmSignInUser(code);

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("given confirm string return general error response", () async {
        when(
          () => authCategory.confirmSignIn(
            confirmationValue: code,
          ),
        ).thenThrow(UnknownException);

        final result = await auth.confirmSignInUser(code);

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("sign up user - ", () {
      test("given email and password return success response", () async {
        when(
          () => authCategory.signUp(username: email, password: password),
        ).thenAnswer((invocation) async {
          return const SignUpResult(
            isSignUpComplete: false,
            nextStep: AuthNextSignUpStep(
              signUpStep: AuthSignUpStep.confirmSignUp,
            ),
          );
        });

        final result = await auth.signUpUser(email, password);

        expect(result.status, AuthStatus.done);
      });

      test("given email and password return error response", () async {
        when(
          () => authCategory.signUp(username: email, password: password),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.signUpUser(email, password);

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("given email and password return general error response", () async {
        when(
          () => authCategory.signUp(username: email, password: password),
        ).thenThrow(UnknownException);

        final result = await auth.signUpUser(email, password);

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("reset password - ", () {
      test("given email return success response", () async {
        when(
          () => authCategory.resetPassword(username: email),
        ).thenAnswer((invocation) async {
          return const CognitoResetPasswordResult(
            isPasswordReset: false,
            nextStep: ResetPasswordStep(
              updateStep: AuthResetPasswordStep.confirmResetPasswordWithCode,
            ),
          );
        });

        final result = await auth.resetPassword(email);

        expect(result.status, AuthStatus.done);
      });

      test("given email return error response", () async {
        when(
          () => authCategory.resetPassword(username: email),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.resetPassword(email);

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("given email return general error response", () async {
        when(
          () => authCategory.resetPassword(username: email),
        ).thenThrow(UnknownException);

        final result = await auth.resetPassword(email);

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("confirm reset password - ", () {
      test("given email, code and new password return success response",
          () async {
        when(
          () => authCategory.confirmResetPassword(
              username: email, newPassword: password, confirmationCode: code),
        ).thenAnswer((invocation) async {
          return const CognitoResetPasswordResult(
            isPasswordReset: true,
            nextStep: ResetPasswordStep(
              updateStep: AuthResetPasswordStep.done,
            ),
          );
        });

        final result = await auth.confirmResetPassword(email, code, password);

        expect(result.status, AuthStatus.done);
      });

      test("given email, code and new password return error response",
          () async {
        when(
          () => authCategory.confirmResetPassword(
              username: email, newPassword: password, confirmationCode: code),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.confirmResetPassword(email, code, password);

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("given email, code and new password return general error response",
          () async {
        when(
          () => authCategory.confirmResetPassword(
              username: email, newPassword: password, confirmationCode: code),
        ).thenThrow(UnknownException);

        final result = await auth.confirmResetPassword(email, code, password);

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("get email - ", () {
      test("get user email with success response", () async {
        when(
          () => authCategory.fetchUserAttributes(),
        ).thenAnswer((invocation) async {
          return [
            AuthUserAttribute(
              userAttributeKey: CognitoUserAttributeKey.email,
              value: email,
            ),
          ];
        });

        final result = await auth.getEmail();

        expect(result.status, AuthStatus.done);
        expect(result.message, email);
      });

      test("get user email error response", () async {
        when(
          () => authCategory.fetchUserAttributes(),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.getEmail();

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("get user email general error response", () async {
        when(
          () => authCategory.fetchUserAttributes(),
        ).thenThrow(UnknownException);

        final result = await auth.getEmail();

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("setup mfa - ", () {
      test("setup mfa with success response", () async {
        when(
          () => authCategory.fetchUserAttributes(),
        ).thenAnswer((invocation) async {
          return [
            AuthUserAttribute(
              userAttributeKey: CognitoUserAttributeKey.email,
              value: email,
            ),
          ];
        });

        when(
          () => authCategory.setUpTotp(),
        ).thenAnswer((invocation) async {
          return TotpSetupDetails(
            sharedSecret: code,
            username: email,
          );
        });

        final result = await auth.setupMfa(email);

        expect(result.status, AuthStatus.done);
        expect(result.message, code);
        expect(result.url, isA<Uri>());
      });

      test("setup mfa with error response", () async {
        when(
          () => authCategory.fetchUserAttributes(),
        ).thenAnswer((invocation) async {
          return [
            AuthUserAttribute(
              userAttributeKey: CognitoUserAttributeKey.email,
              value: email,
            ),
          ];
        });

        when(
          () => authCategory.setUpTotp(),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.setupMfa(email);

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("setup mfa with success response", () async {
        when(
          () => authCategory.fetchUserAttributes(),
        ).thenAnswer((invocation) async {
          return [
            AuthUserAttribute(
              userAttributeKey: CognitoUserAttributeKey.email,
              value: email,
            ),
          ];
        });

        when(
          () => authCategory.setUpTotp(),
        ).thenThrow(UnknownException);

        final result = await auth.setupMfa(email);

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("verify mfa setup - ", () {
      test("given code return success response", () async {
        when(
          () => authCategory.verifyTotpSetup(code),
        ).thenAnswer((invocation) async {
          return;
        });

        when(
          () => authCategory.getPlugin(AmplifyAuthCognito.pluginKey),
        ).thenReturn(amplifyAuthCognito);

        when(
          () => amplifyAuthCognito.updateMfaPreference(
            totp: MfaPreference.preferred,
          ),
        ).thenAnswer((invocation) async {
          return;
        });

        final result = await auth.verifyMfaSetup(code);

        expect(result.status, AuthStatus.done);
      });

      test("given code return error response", () async {
        when(
          () => authCategory.verifyTotpSetup(code),
        ).thenThrow(CodeMismatchException(authExceptionString));

        final result = await auth.verifyMfaSetup(code);

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("given code return success response", () async {
        when(
          () => authCategory.verifyTotpSetup(code),
        ).thenThrow(UnknownException);

        final result = await auth.verifyMfaSetup(code);

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("get access token - ", () {
      test("get access token success response", () async {
        when(
          () => authCategory.getPlugin(AmplifyAuthCognito.pluginKey),
        ).thenReturn(amplifyAuthCognito);

        when(
          () => amplifyAuthCognito.fetchAuthSession(),
        ).thenAnswer((invocation) async {
          return authSession;
        });

        when(
          () => authSession.userPoolTokensResult,
        ).thenReturn(authSuccessResult);

        when(
          () => authSuccessResult.value.accessToken,
        ).thenReturn(token);

        when(
          () => token.raw,
        ).thenReturn(accessToken);

        final result = await auth.getAccessToken();

        expect(result.status, AuthStatus.done);
        expect(result.value, accessToken);
      });

      test("get access token error response", () async {
        when(
          () => authCategory.getPlugin(AmplifyAuthCognito.pluginKey),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.getAccessToken();

        expect(result.status, AuthStatus.error);
        expect(result.value, authExceptionString);
      });

      test("get access token error response", () async {
        when(
          () => authCategory.getPlugin(AmplifyAuthCognito.pluginKey),
        ).thenThrow(UnknownException);

        final result = await auth.getAccessToken();

        expect(result.status, AuthStatus.error);
        expect(result.value, Constants.errorMessage);
      });
    });

    group("updated password - ", () {
      test("given old password and new password return success response",
          () async {
        when(
          () => authCategory.updatePassword(
              oldPassword: password, newPassword: password),
        ).thenAnswer((_) async {
          return const UpdatePasswordResult();
        });

        final result = await auth.updatePassword(password, password);

        expect(result.status, AuthStatus.done);
      });

      test("given old password and new password return error response",
          () async {
        when(
          () => authCategory.updatePassword(
              oldPassword: password, newPassword: password),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.updatePassword(password, password);

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("given old password and new password return success response",
          () async {
        when(
          () => authCategory.updatePassword(
              oldPassword: password, newPassword: password),
        ).thenThrow(UnknownException);

        final result = await auth.updatePassword(password, password);

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });

    group("get user id - ", () {
      test("get user id success response", () async {
        when(
          () => authCategory.getCurrentUser(),
        ).thenAnswer((invocation) async {
          return AuthUser(
            userId: userId,
            username: email,
            signInDetails: CognitoSignInDetails.apiBased(
              username: email,
            ),
          );
        });

        final result = await auth.getUserId();

        expect(result.status, AuthStatus.done);
        expect(result.message, userId);
      });

      test("get user id error response", () async {
        when(
          () => authCategory.getCurrentUser(),
        ).thenThrow(AuthNotAuthorizedException(authExceptionString));

        final result = await auth.getUserId();

        expect(result.status, AuthStatus.error);
        expect(result.message, authExceptionString);
      });

      test("get user id general error response", () async {
        when(
          () => authCategory.getCurrentUser(),
        ).thenThrow(UnknownException);

        final result = await auth.getUserId();

        expect(result.status, AuthStatus.error);
        expect(result.message, Constants.errorMessage);
      });
    });
  });
}
