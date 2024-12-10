import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:amplify_storage_s3/amplify_storage_s3.dart";
import "package:doko_react/archive/core/configs/graphql/graphql_config.dart";
import "package:doko_react/features/authentication/data/data-sources/authentication_remote_data_source.dart";
import "package:doko_react/features/authentication/data/repository/authentication_repository_impl.dart";
import "package:doko_react/features/authentication/domain/repository/authentication_repository.dart";
import "package:doko_react/features/authentication/domain/use-cases/login-use-case/confirm_login_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/login-use-case/login_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/logout-use-case/logout_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/mfa-use-case/remove_mfa_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/mfa-use-case/setup_mfa_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/mfa-use-case/verify_mfa_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/password-use-case/confirm_reset_password_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/password-use-case/reset_password_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/password-use-case/update_password_use_case.dart";
import "package:doko_react/features/authentication/domain/use-cases/sign-up-use-case/sign_up_use_case.dart";
import "package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart";
import "package:doko_react/features/complete-profile/data/data-sources/complete_profile_remote_data_source.dart";
import "package:doko_react/features/complete-profile/data/repository/complete_profile_repository_impl.dart";
import "package:doko_react/features/complete-profile/domain/repository/complete_profile_repository.dart";
import "package:doko_react/features/complete-profile/domain/use-case/complete-profile-use-case/complete_profile_use_case.dart";
import "package:doko_react/features/complete-profile/domain/use-case/username-use-case/username_use_case.dart";
import "package:doko_react/features/complete-profile/presentation/bloc/complete_profile_bloc.dart";
import "package:doko_react/features/user-profile/bloc/user_action_bloc.dart";
import "package:doko_react/features/user-profile/data/data-sources/user_profile_remote_data_source.dart";
import "package:doko_react/features/user-profile/data/repository/user_profile_repository_impl.dart";
import "package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart";
import "package:doko_react/features/user-profile/domain/use-case/comments/comment_add_like_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/comments/comment_remove_like_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/posts/post_add_like_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/posts/post_remove_like_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_accepts_friend_relation_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_create_friend_relation_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_remove_friend_relation_use_case.dart";
import "package:doko_react/features/user-profile/user-features/node-create/data/data-source/node_create_remote_data_source.dart";
import "package:doko_react/features/user-profile/user-features/node-create/data/repository/node_create_repository_impl.dart";
import "package:doko_react/features/user-profile/user-features/node-create/domain/repository/node_create_repository.dart";
import "package:doko_react/features/user-profile/user-features/node-create/domain/use-case/post-create-use-case/post_create_use_case.dart";
import "package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart";
import "package:doko_react/features/user-profile/user-features/post/data/data-source/post_remote_data_source.dart";
import "package:doko_react/features/user-profile/user-features/post/data/repository/post_repository_impl.dart";
import "package:doko_react/features/user-profile/user-features/post/domain/repository/post_repository.dart";
import "package:doko_react/features/user-profile/user-features/post/domain/use-case/comments-use-case/comments_use_case.dart";
import "package:doko_react/features/user-profile/user-features/post/domain/use-case/comments-use-case/replies_use_case.dart";
import "package:doko_react/features/user-profile/user-features/post/domain/use-case/post-use-case/post_use_case.dart";
import "package:doko_react/features/user-profile/user-features/post/presentation/bloc/post_bloc.dart";
import "package:doko_react/features/user-profile/user-features/profile/data/data-sources/profile_remote_data_source.dart";
import "package:doko_react/features/user-profile/user-features/profile/data/repository/profile_repository_impl.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/edit-profile-use-case/edit_profile_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/pending-request-use-case/pending_incoming_request_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/pending-request-use-case/pending_outgoing_request_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/profile-use-case/profile_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-friends-use-case/user_friends_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-post-use-case/user_post_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/user_friend_search_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/user_search_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart";
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
  _initProfile();
  _initUserAction();
  _initNodeCreate();
  _initPost();
}

void _initPost() {
  serviceLocator.registerFactory<PostRemoteDataSource>(
        () =>
        PostRemoteDataSource(
          client: serviceLocator<GraphQLClient>(),
        ),
  );

  serviceLocator.registerFactory<PostRepository>(
        () =>
        PostRepositoryImpl(
          remoteDataSource: serviceLocator<PostRemoteDataSource>(),
        ),
  );

  serviceLocator.registerFactory<PostUseCase>(
        () =>
        PostUseCase(
          postRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<CommentsUseCase>(
        () =>
        CommentsUseCase(
          postRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<RepliesUseCase>(
        () =>
        RepliesUseCase(
          postRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<PostBloc>(
        () =>
        PostBloc(
          postUseCase: serviceLocator(),
          commentsUseCase: serviceLocator(),
          repliesUseCase: serviceLocator(),
        ),
  );
}

void _initNodeCreate() {
  serviceLocator.registerFactory<NodeCreateRemoteDataSource>(
        () =>
        NodeCreateRemoteDataSource(
          client: serviceLocator<GraphQLClient>(),
        ),
  );

  serviceLocator.registerFactory<NodeCreateRepository>(
        () =>
        NodeCreateRepositoryImpl(
          remoteDataSource: serviceLocator<NodeCreateRemoteDataSource>(),
        ),
  );

  serviceLocator.registerFactory<PostCreateUseCase>(
        () =>
        PostCreateUseCase(
          nodeCreateRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<NodeCreateBloc>(
        () =>
        NodeCreateBloc(
          postCreateUseCase: serviceLocator(),
        ),
  );
}

void _initUserAction() {
  serviceLocator.registerFactory<UserProfileRemoteDataSource>(
        () =>
        UserProfileRemoteDataSource(
          client: serviceLocator<GraphQLClient>(),
        ),
  );

  serviceLocator.registerFactory<UserProfileRepository>(
        () =>
        UserProfileRepositoryImpl(
          remoteDataSource: serviceLocator<UserProfileRemoteDataSource>(),
        ),
  );

  serviceLocator.registerFactory<PostAddLikeUseCase>(
        () =>
        PostAddLikeUseCase(
          profileRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<PostRemoveLikeUseCase>(
        () =>
        PostRemoveLikeUseCase(
          profileRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<UserCreateFriendRelationUseCase>(
        () =>
        UserCreateFriendRelationUseCase(
          profileRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<UserAcceptFriendRelationUseCase>(
        () =>
        UserAcceptFriendRelationUseCase(
          profileRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<UserRemoveFriendRelationUseCase>(
        () =>
        UserRemoveFriendRelationUseCase(
          profileRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<CommentAddLikeUseCase>(
        () =>
        CommentAddLikeUseCase(
          profileRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<CommentRemoveLikeUseCase>(
        () =>
        CommentRemoveLikeUseCase(
          profileRepository: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<UserActionBloc>(
        () =>
        UserActionBloc(
          postAddLikeUseCase: serviceLocator(),
          postRemoveLikeUseCase: serviceLocator(),
          userCreateFriendRelationUseCase: serviceLocator(),
          userRemoveFriendRelationUseCase: serviceLocator(),
          userAcceptFriendRelationUseCase: serviceLocator(),
          commentAddLikeUseCase: serviceLocator(),
          commentRemoveLikeUseCase: serviceLocator(),
        ),
  );
}

void _initProfile() {
  serviceLocator.registerFactory<ProfileRemoteDataSource>(
        () =>
        ProfileRemoteDataSource(
          client: serviceLocator<GraphQLClient>(),
        ),
  );

  serviceLocator.registerFactory<ProfileRepository>(
        () =>
        ProfileRepositoryImpl(
          remoteDataSource: serviceLocator<ProfileRemoteDataSource>(),
        ),
  );

  serviceLocator.registerFactory<ProfileUseCase>(
        () =>
        ProfileUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<EditProfileUseCase>(
        () =>
        EditProfileUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<UserPostUseCase>(
        () =>
        UserPostUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<UserFriendsUseCase>(
        () =>
        UserFriendsUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<UserSearchUseCase>(
        () =>
        UserSearchUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<UserFriendsSearchUseCase>(
        () =>
        UserFriendsSearchUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<PendingOutgoingRequestUseCase>(
        () =>
        PendingOutgoingRequestUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<PendingIncomingRequestUseCase>(
        () =>
        PendingIncomingRequestUseCase(
          profileRepository: serviceLocator<ProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<ProfileBloc>(
        () =>
        ProfileBloc(
          profileUseCase: serviceLocator(),
          editProfileUseCase: serviceLocator(),
          userPostUseCase: serviceLocator(),
          userFriendsUseCase: serviceLocator(),
          userSearchUseCase: serviceLocator(),
          userFriendsSearchUseCase: serviceLocator(),
          pendingIncomingRequestUseCase: serviceLocator(),
          pendingOutgoingRequestUseCase: serviceLocator(),
        ),
  );
}

void _initAuth() {
  serviceLocator.registerFactory<AuthenticationRemoteDataSource>(
        () =>
        AuthenticationRemoteDataSource(
          auth: serviceLocator<AuthCategory>(),
        ),
  );

  serviceLocator.registerFactory<AuthenticationRepository>(
        () =>
        AuthenticationRepositoryImpl(
          authenticationRemoteDataSource:
          serviceLocator<AuthenticationRemoteDataSource>(),
        ),
  );

  // for login use case
  serviceLocator.registerFactory<LoginUseCase>(
        () =>
        LoginUseCase(
          auth: serviceLocator(),
        ),
  );

  // for confirm login use case
  serviceLocator.registerFactory<ConfirmLoginUseCase>(
        () =>
        ConfirmLoginUseCase(
          auth: serviceLocator(),
        ),
  );

  // for sign up use case
  serviceLocator.registerFactory<SignUpUseCase>(
        () =>
        SignUpUseCase(
          auth: serviceLocator(),
        ),
  );

  // for reset password use case
  serviceLocator.registerFactory<ResetPasswordUseCase>(
        () =>
        ResetPasswordUseCase(
          auth: serviceLocator(),
        ),
  );

  // for confirm reset password use case
  serviceLocator.registerFactory<ConfirmResetPasswordUseCase>(
        () =>
        ConfirmResetPasswordUseCase(
          auth: serviceLocator(),
        ),
  );

  // for update password use case
  serviceLocator.registerFactory<UpdatePasswordUseCase>(
        () =>
        UpdatePasswordUseCase(
          auth: serviceLocator(),
        ),
  );

  // for logout use case
  serviceLocator.registerFactory<LogoutUseCase>(
        () =>
        LogoutUseCase(
          auth: serviceLocator(),
        ),
  );

  // for remove mfa use case
  serviceLocator.registerFactory<RemoveMFAUseCase>(
        () =>
        RemoveMFAUseCase(
          auth: serviceLocator(),
        ),
  );

  // for mfa setup use case
  serviceLocator.registerFactory<SetupMFAUseCase>(
        () =>
        SetupMFAUseCase(
          auth: serviceLocator(),
        ),
  );

  // for mfa verify use case
  serviceLocator.registerFactory<VerifyMFAUseCase>(
        () =>
        VerifyMFAUseCase(
          auth: serviceLocator(),
        ),
  );

  serviceLocator.registerFactory<AuthenticationBloc>(
        () =>
        AuthenticationBloc(
          loginUseCase: serviceLocator<LoginUseCase>(),
          confirmLoginUseCase: serviceLocator<ConfirmLoginUseCase>(),
          signUpUseCase: serviceLocator<SignUpUseCase>(),
          resetPasswordUseCase: serviceLocator<ResetPasswordUseCase>(),
          confirmResetPasswordUseCase:
          serviceLocator<ConfirmResetPasswordUseCase>(),
          updatePasswordUseCase: serviceLocator<UpdatePasswordUseCase>(),
          logoutUseCase: serviceLocator<LogoutUseCase>(),
          removeMFAUseCase: serviceLocator<RemoveMFAUseCase>(),
          setupMFAUseCase: serviceLocator<SetupMFAUseCase>(),
          verifyMFAUseCase: serviceLocator<VerifyMFAUseCase>(),
        ),
  );
}

void _initCompleteProfile() {
  serviceLocator.registerFactory<CompleteProfileRemoteDataSource>(
        () =>
        CompleteProfileRemoteDataSource(
          client: serviceLocator<GraphQLClient>(),
        ),
  );

  serviceLocator.registerFactory<CompleteProfileRepository>(
        () =>
        CompleteProfileRepositoryImpl(
          remoteDataSource: serviceLocator<CompleteProfileRemoteDataSource>(),
        ),
  );

  // username check use case
  serviceLocator.registerFactory<UsernameUseCase>(
        () =>
        UsernameUseCase(
          completeProfile: serviceLocator<CompleteProfileRepository>(),
        ),
  );

  // complete profile details use case
  serviceLocator.registerFactory<CompleteProfileUseCase>(
        () =>
        CompleteProfileUseCase(
          completeProfile: serviceLocator<CompleteProfileRepository>(),
        ),
  );

  serviceLocator.registerFactory<CompleteProfileBloc>(
        () =>
        CompleteProfileBloc(
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
