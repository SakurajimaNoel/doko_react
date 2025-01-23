import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart' hide Emitter;
import 'package:doko_react/core/config/graphql/graphql_config.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoadingState()) {
    on<UserInitEvent>(_handleInit);
    on<UserAuthenticatedEvent>(_handeUserFetch);
    on<UserSignOutEvent>(_handleSignOut);
    on<UserProfileCompleteEvent>(_handleUserProfileCompleteEvent);
    on<UserUpdateMFAEvent>(_handleUserUpdateMFAEvent);
  }

  FutureOr<void> _handleInit(
      UserInitEvent event, Emitter<UserState> emit) async {
    try {
      // also reset graph
      UserGraph().reset();
      final result = await Amplify.Auth.fetchAuthSession();

      if (result.isSignedIn) {
        add(UserAuthenticatedEvent());
        return;
      }
      emit(UserUnauthenticatedState());
    } on ApplicationException catch (_) {
      emit(UserUnauthenticatedState());
    } catch (e) {
      emit(UserAuthErrorState());
    }
  }

  FutureOr<void> _handeUserFetch(
      UserAuthenticatedEvent event, Emitter<UserState> emit) async {
    try {
      emit(UserLoadingState());
      final userDetails = await getUser();
      GraphQLClient client = GraphqlConfig.getGraphQLClient();

      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getUser()),
          variables: GraphqlQueries.getUserVariables(userDetails.userId),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        var email = (userDetails.signInDetails as CognitoSignInDetailsApiBased)
            .username;

        emit(UserIncompleteState(
          id: userDetails.userId,
          email: email,
        ));
        return;
      }

      String username = res[0]["username"];
      bool mfaStatus = await getUserMFAStatus();

      final UserEntity currentUser = await UserEntity.createEntity(map: res[0]);

      final UserGraph graph = UserGraph();
      String key = generateUserNodeKey(username);
      graph.addEntity(key, currentUser);

      emit(UserCompleteState(
        id: userDetails.userId,
        email: userDetails.username,
        username: username,
        userMfa: mfaStatus,
      ));

      String preferredUsername = await getUsername();
      // add preferred username to user attributes if not present
      if (preferredUsername.isEmpty) {
        // add to username to user
        await addUsername(username);
        await refreshAuthSession();
      }
    } on ApplicationException catch (_) {
      emit(UserAuthErrorState());
    } catch (e) {
      safePrint(e.toString());
      emit(UserGraphErrorState());
    }
  }

  FutureOr<void> _handleSignOut(
      UserSignOutEvent event, Emitter<UserState> emit) {
    emit(UserUnauthenticatedState());
  }

  FutureOr<void> _handleUserProfileCompleteEvent(
      UserProfileCompleteEvent event, Emitter<UserState> emit) async {
    try {
      String userId = event.userId;
      String username = event.username;
      String email = event.email;

      emit(UserLoadingState());
      bool mfaStatus = await getUserMFAStatus();
      emit(UserCompleteState(
        id: userId,
        email: email,
        username: username,
        userMfa: mfaStatus,
      ));
    } on ApplicationException catch (_) {
      emit(UserUnauthenticatedState());
    } catch (e) {
      emit(UserAuthErrorState());
    }
  }

  FutureOr<void> _handleUserUpdateMFAEvent(
      UserUpdateMFAEvent event, Emitter<UserState> emit) async {
    if (state is! UserCompleteState) return;

    emit((state as UserCompleteState).updateMFA(event.mfaStatus));
  }
}
