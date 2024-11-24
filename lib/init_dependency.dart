import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:amplify_storage_s3/amplify_storage_s3.dart";
import "package:doko_react/archive/core/configs/graphql/graphql_config.dart";
import "package:doko_react/features/authentication/data/data-sources/authentication_remote_data_source.dart";
import "package:doko_react/features/authentication/data/repositories/authentication_repository_impl.dart";
import "package:doko_react/features/authentication/domain/repositories/authentication_repository.dart";
import "package:doko_react/features/authentication/domain/use-cases/login-use-case/confirm_login_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/login-use-case/login_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/logout-use-case/logout_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/password-use-case/confirm_reset_password_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/password-use-case/reset_password_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/password-use-case/update_reset_password_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/sign-up-use-case/sign_up_use_case.dart";
import "package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart";
import "package:doko_react/features/complete-profile/data/data-sources/complete_profile_remote_data_source.dart";
import "package:doko_react/features/complete-profile/data/repositories/complete_profile_repository_impl.dart";
import "package:doko_react/features/complete-profile/domain/repositories/complete_profile_repository.dart";
import "package:doko_react/features/complete-profile/domain/use-case/complete-profile-user-case/complete_profile_use_case.dart";
import "package:doko_react/features/complete-profile/domain/use-case/username-use-case/username_use_case.dart";
import "package:doko_react/features/complete-profile/presentation/bloc/complete_profile_bloc.dart";
import "package:flutter/foundation.dart";
import "package:get_it/get_it.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";

import "aws/amplifyconfiguration.dart";

final serviceLocator = GetIt.instance;

Future<void> initDependency() async {
  await _configureAmplify();
  await initHiveForFlutter();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  serviceLocator.registerLazySingleton<GraphQLClient>(
    () => GraphqlConfig.getGraphQLClient(),
  );

  serviceLocator.registerLazySingleton<AuthCategory>(
    () => Amplify.Auth,
  );

  _initAuth();
  _initCompleteProfile();
}

void _initAuth() {
  serviceLocator.registerFactory<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSource(
      auth: serviceLocator<AuthCategory>(),
    ),
  );

  serviceLocator.registerFactory<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      authenticationRemoteDataSource:
          serviceLocator<AuthenticationRemoteDataSource>(),
    ),
  );

  // for login use case
  serviceLocator.registerFactory<LoginUseCase>(
    () => LoginUseCase(
      auth: serviceLocator(),
    ),
  );

  // for confirm login use case
  serviceLocator.registerFactory<ConfirmLoginUseCase>(
    () => ConfirmLoginUseCase(
      auth: serviceLocator(),
    ),
  );

  // for sign up use case
  serviceLocator.registerFactory<SignUpUseCase>(
    () => SignUpUseCase(
      auth: serviceLocator(),
    ),
  );

  // for reset password use case
  serviceLocator.registerFactory<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(
      auth: serviceLocator(),
    ),
  );

  // for confirm reset password use case
  serviceLocator.registerFactory<ConfirmResetPasswordUseCase>(
    () => ConfirmResetPasswordUseCase(
      auth: serviceLocator(),
    ),
  );

  // for update password use case
  serviceLocator.registerFactory<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(
      auth: serviceLocator(),
    ),
  );

  // for logout use case
  serviceLocator.registerFactory<LogoutUseCase>(
    () => LogoutUseCase(
      auth: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(
      loginUseCase: serviceLocator<LoginUseCase>(),
      confirmLoginUseCase: serviceLocator<ConfirmLoginUseCase>(),
      signUpUseCase: serviceLocator<SignUpUseCase>(),
      resetPasswordUseCase: serviceLocator<ResetPasswordUseCase>(),
      confirmResetPasswordUseCase:
          serviceLocator<ConfirmResetPasswordUseCase>(),
      updatePasswordUseCase: serviceLocator<UpdatePasswordUseCase>(),
      logoutUseCase: serviceLocator<LogoutUseCase>(),
    ),
  );
}

void _initCompleteProfile() {
  serviceLocator.registerFactory<CompleteProfileRemoteDataSource>(
    () => CompleteProfileRemoteDataSource(
      client: serviceLocator<GraphQLClient>(),
    ),
  );

  serviceLocator.registerFactory<CompleteProfileRepository>(
    () => CompleteProfileRepositoryImpl(
      remoteDataSource: serviceLocator<CompleteProfileRemoteDataSource>(),
    ),
  );

  // username check use case
  serviceLocator.registerFactory<UsernameUseCase>(
    () => UsernameUseCase(
      completeProfile: serviceLocator<CompleteProfileRepository>(),
    ),
  );

  // complete profile details use case
  serviceLocator.registerFactory<CompleteProfileUseCase>(
    () => CompleteProfileUseCase(
      completeProfile: serviceLocator<CompleteProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<CompleteProfileBloc>(
    () => CompleteProfileBloc(
      usernameUseCase: serviceLocator<UsernameUseCase>(),
      completeProfileUseCase: serviceLocator<CompleteProfileUseCase>(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.addPlugin(AmplifyStorageS3());
    await Amplify.configure(amplifyconfig);

    safePrint("Successfully configured amplify");
  } on Exception catch (e) {
    safePrint("Error configuring Amplify: $e");
  }
}
