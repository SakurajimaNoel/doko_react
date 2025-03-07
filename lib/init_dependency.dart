import "package:amplify_api/amplify_api.dart";
import "package:amplify_auth_cognito/amplify_auth_cognito.dart";
import "package:amplify_flutter/amplify_flutter.dart";
import "package:amplify_storage_s3/amplify_storage_s3.dart";
import "package:doko_react/core/config/graphql/graphql_config.dart";
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
import "package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart";
import "package:doko_react/features/user-profile/bloc/user-to-user-action/user_to_user_action_bloc.dart";
import "package:doko_react/features/user-profile/data/data-sources/user_profile_remote_data_source.dart";
import "package:doko_react/features/user-profile/data/repository/user_profile_repository_impl.dart";
import "package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart";
import "package:doko_react/features/user-profile/domain/use-case/comments/comment_get.dart";
import "package:doko_react/features/user-profile/domain/use-case/discussion/discussion_get.dart";
import "package:doko_react/features/user-profile/domain/use-case/poll/poll_get.dart";
import "package:doko_react/features/user-profile/domain/use-case/poll/user_add_vote_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/posts/post_get.dart";
import "package:doko_react/features/user-profile/domain/use-case/user-node-action/user_node_like_action_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_accepts_friend_relation_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_create_friend_relation_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_remove_friend_relation_use_case.dart";
import "package:doko_react/features/user-profile/domain/use-case/user/user_get.dart";
import "package:doko_react/features/user-profile/user-features/node-create/data/data-source/node_create_remote_data_source.dart";
import "package:doko_react/features/user-profile/user-features/node-create/data/repository/node_create_repository_impl.dart";
import "package:doko_react/features/user-profile/user-features/node-create/domain/repository/node_create_repository.dart";
import "package:doko_react/features/user-profile/user-features/node-create/domain/use-case/comment-use-case/create_comment_use_case.dart";
import "package:doko_react/features/user-profile/user-features/node-create/domain/use-case/discussion-use-case/discussion_create_use_case.dart";
import "package:doko_react/features/user-profile/user-features/node-create/domain/use-case/poll-use-case/poll_create_use_case.dart";
import "package:doko_react/features/user-profile/user-features/node-create/domain/use-case/post-create-use-case/post_create_use_case.dart";
import "package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart";
import "package:doko_react/features/user-profile/user-features/profile/data/data-sources/profile_remote_data_source.dart";
import "package:doko_react/features/user-profile/user-features/profile/data/repository/profile_repository_impl.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/edit-profile-use-case/edit_profile_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/pending-request-use-case/pending_incoming_request_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/pending-request-use-case/pending_outgoing_request_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/profile-use-case/profile_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-discussion-use-case/user_discussion_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-friends-use-case/user_friends_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-poll-use-case/user_poll_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-post-use-case/user_post_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/comments_mention_search_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/user_friend_search_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/user_search_use_case.dart";
import "package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart";
import "package:doko_react/features/user-profile/user-features/root-node/data/data-source/post_remote_data_source.dart";
import "package:doko_react/features/user-profile/user-features/root-node/data/repository/root_node_repository_impl.dart";
import "package:doko_react/features/user-profile/user-features/root-node/domain/repository/root_node_repository.dart";
import "package:doko_react/features/user-profile/user-features/root-node/domain/use-case/comments-use-case/comments_use_case.dart";
import "package:doko_react/features/user-profile/user-features/root-node/domain/use-case/comments-use-case/comments_with_replies_use_case.dart";
import "package:doko_react/features/user-profile/user-features/root-node/domain/use-case/discussion-use-case/discussion_use_case.dart";
import "package:doko_react/features/user-profile/user-features/root-node/domain/use-case/poll-use-case/poll_use_case.dart";
import "package:doko_react/features/user-profile/user-features/root-node/domain/use-case/post-use-case/post_use_case.dart";
import "package:doko_react/features/user-profile/user-features/root-node/presentation/bloc/root_node_bloc.dart";
import "package:doko_react/features/user-profile/user-features/user-feed/data/data-sources/user_feed_remote_data_source.dart";
import "package:doko_react/features/user-profile/user-features/user-feed/data/repository/user_feed_repo_impl.dart";
import "package:doko_react/features/user-profile/user-features/user-feed/domain/repository/user_feed_repo.dart";
import "package:doko_react/features/user-profile/user-features/user-feed/domain/use-case/user-feed-content/content_use_case.dart";
import "package:doko_react/features/user-profile/user-features/user-feed/presentation/bloc/user_feed_bloc.dart";
import "package:doko_react/models/ModelProvider.dart";
import "package:flutter/foundation.dart";
import "package:get_it/get_it.dart";
import "package:hive_flutter/adapters.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";

import "aws/amplifyconfiguration.dart";
import "features/user-profile/user-features/profile/domain/use-case/profile-use-case/timeline_use_case.dart";

final serviceLocator = GetIt.instance;

Future<void> initDependency() async {
  await _configureAmplify();
  await Hive.initFlutter();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  serviceLocator.registerLazySingleton<GraphApiClient>(
    () => GraphqlConfig.getApiGraphQLClient(),
  );

  serviceLocator.registerLazySingleton<MessageArchiveApiClient>(
    () => GraphqlConfig.getMessageArchiveGraphQLClient(),
  );

  serviceLocator.registerLazySingleton<AuthCategory>(
    () => Amplify.Auth,
  );

  _initAuth();
  _initCompleteProfile();
  _initUserFeed();
  _initProfile();
  _initUserAction();
  _initUserToUserAction();
  _initNodeCreate();
  _initPost();
}

void _initUserFeed() {
  serviceLocator.registerFactory<UserFeedRemoteDataSource>(
    () => UserFeedRemoteDataSource(
      client: serviceLocator<GraphApiClient>().client,
    ),
  );

  serviceLocator.registerFactory<UserFeedRepo>(
    () => UserFeedRepoImpl(
      remoteDataSource: serviceLocator<UserFeedRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory<ContentUseCase>(
    () => ContentUseCase(
      repo: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserFeedBloc>(
    () => UserFeedBloc(
      contentUseCase: serviceLocator(),
    ),
  );
}

void _initPost() {
  serviceLocator.registerFactory<PostRemoteDataSource>(
    () => PostRemoteDataSource(
      client: serviceLocator<GraphApiClient>().client,
    ),
  );

  serviceLocator.registerFactory<RootNodeRepository>(
    () => RootNodeRepositoryImpl(
      remoteDataSource: serviceLocator<PostRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory<PostUseCase>(
    () => PostUseCase(
      rootNodeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<CommentsUseCase>(
    () => CommentsUseCase(
      rootNodeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DiscussionUseCase>(
    () => DiscussionUseCase(
      rootNodeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<PollUseCase>(
    () => PollUseCase(
      rootNodeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<CommentsWithRepliesUseCase>(
    () => CommentsWithRepliesUseCase(
      rootNodeRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<RootNodeBloc>(
    () => RootNodeBloc(
      postUseCase: serviceLocator(),
      pollUseCase: serviceLocator(),
      discussionUseCase: serviceLocator(),
      commentsUseCase: serviceLocator(),
      commentsWithRepliesUseCase: serviceLocator(),
    ),
  );
}

void _initNodeCreate() {
  serviceLocator.registerFactory<NodeCreateRemoteDataSource>(
    () => NodeCreateRemoteDataSource(
      client: serviceLocator<GraphApiClient>().client,
    ),
  );

  serviceLocator.registerFactory<NodeCreateRepository>(
    () => NodeCreateRepositoryImpl(
      remoteDataSource: serviceLocator<NodeCreateRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory<PostCreateUseCase>(
    () => PostCreateUseCase(
      nodeCreateRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<CreateCommentUseCase>(
    () => CreateCommentUseCase(
      nodeCreateRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DiscussionCreateUseCase>(
    () => DiscussionCreateUseCase(
      nodeCreateRepository: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<PollCreateUseCase>(
    () => PollCreateUseCase(
      nodeCreateRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<NodeCreateBloc>(
    () => NodeCreateBloc(
      postCreateUseCase: serviceLocator(),
      createCommentUseCase: serviceLocator(),
      createDiscussionUseCase: serviceLocator(),
      pollCreateUseCase: serviceLocator(),
    ),
  );
}

void _initUserToUserAction() {
  serviceLocator.registerFactory<UserCreateFriendRelationUseCase>(
    () => UserCreateFriendRelationUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserAcceptFriendRelationUseCase>(
    () => UserAcceptFriendRelationUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserRemoveFriendRelationUseCase>(
    () => UserRemoveFriendRelationUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserGetUseCase>(
    () => UserGetUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserToUserActionBloc>(
    () => UserToUserActionBloc(
      userCreateFriendRelationUseCase: serviceLocator(),
      userRemoveFriendRelationUseCase: serviceLocator(),
      userAcceptFriendRelationUseCase: serviceLocator(),
      userGetUseCase: serviceLocator(),
    ),
  );
}

void _initUserAction() {
  serviceLocator.registerFactory<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSource(
      client: serviceLocator<GraphApiClient>().client,
    ),
  );

  serviceLocator.registerFactory<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: serviceLocator<UserProfileRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory<UserNodeLikeActionUseCase>(
    () => UserNodeLikeActionUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<PostGetUseCase>(
    () => PostGetUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<CommentGetUseCase>(
    () => CommentGetUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<DiscussionGetUseCase>(
    () => DiscussionGetUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<PollGetUseCase>(
    () => PollGetUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserAddVoteUseCase>(
    () => UserAddVoteUseCase(
      profileRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<UserActionBloc>(
    () => UserActionBloc(
      userNodeLikeActionUseCase: serviceLocator(),
      postGetUseCase: serviceLocator(),
      discussionGetUseCase: serviceLocator(),
      pollGetUseCase: serviceLocator(),
      commentGetUseCase: serviceLocator(),
      userAddVoteUseCase: serviceLocator(),
    ),
  );
}

void _initProfile() {
  serviceLocator.registerFactory<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(
      client: serviceLocator<GraphApiClient>().client,
    ),
  );

  serviceLocator.registerFactory<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: serviceLocator<ProfileRemoteDataSource>(),
    ),
  );

  serviceLocator.registerFactory<ProfileUseCase>(
    () => ProfileUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<EditProfileUseCase>(
    () => EditProfileUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<UserPostUseCase>(
    () => UserPostUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<UserFriendsUseCase>(
    () => UserFriendsUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<UserSearchUseCase>(
    () => UserSearchUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<UserFriendsSearchUseCase>(
    () => UserFriendsSearchUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<PendingOutgoingRequestUseCase>(
    () => PendingOutgoingRequestUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<PendingIncomingRequestUseCase>(
    () => PendingIncomingRequestUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<CommentsMentionSearchUseCase>(
    () => CommentsMentionSearchUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<TimelineUseCase>(
    () => TimelineUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<UserDiscussionUseCase>(
    () => UserDiscussionUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );
  serviceLocator.registerFactory<UserPollUseCase>(
    () => UserPollUseCase(
      profileRepository: serviceLocator<ProfileRepository>(),
    ),
  );

  serviceLocator.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      profileUseCase: serviceLocator(),
      timelineUseCase: serviceLocator(),
      editProfileUseCase: serviceLocator(),
      userPostUseCase: serviceLocator(),
      userDiscussionUseCase: serviceLocator(),
      userPollUseCase: serviceLocator(),
      userFriendsUseCase: serviceLocator(),
      userSearchUseCase: serviceLocator(),
      userFriendsSearchUseCase: serviceLocator(),
      pendingIncomingRequestUseCase: serviceLocator(),
      pendingOutgoingRequestUseCase: serviceLocator(),
      commentMentionSearchUseCase: serviceLocator(),
    ),
  );
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

  // for remove mfa use case
  serviceLocator.registerFactory<RemoveMFAUseCase>(
    () => RemoveMFAUseCase(
      auth: serviceLocator(),
    ),
  );

  // for mfa setup use case
  serviceLocator.registerFactory<SetupMFAUseCase>(
    () => SetupMFAUseCase(
      auth: serviceLocator(),
    ),
  );

  // for mfa verify use case
  serviceLocator.registerFactory<VerifyMFAUseCase>(
    () => VerifyMFAUseCase(
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
      removeMFAUseCase: serviceLocator<RemoveMFAUseCase>(),
      setupMFAUseCase: serviceLocator<SetupMFAUseCase>(),
      verifyMFAUseCase: serviceLocator<VerifyMFAUseCase>(),
    ),
  );
}

void _initCompleteProfile() {
  serviceLocator.registerFactory<CompleteProfileRemoteDataSource>(
    () => CompleteProfileRemoteDataSource(
      client: serviceLocator<GraphApiClient>().client,
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
    await Amplify.addPlugin(
      AmplifyAPI(
        options: APIPluginOptions(
          modelProvider: ModelProvider.instance,
        ),
      ),
    );
    await Amplify.configure(amplifyconfig);

    safePrint("Successfully configured amplify");
  } on Exception catch (e) {
    safePrint("Error configuring Amplify: $e");
  }
}
