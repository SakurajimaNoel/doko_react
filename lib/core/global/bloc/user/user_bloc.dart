import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart' hide Emitter;
import 'package:doko_react/core/config/graphql/graphql_config.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoadingState()) {
    on<UserInitEvent>(_handleInit);
    on<UserAuthenticatedEvent>(_handeUserFetch);
    on<UserSignOutEvent>(_handleSignOut);
    on<UserProfileCompleteEvent>(_handleUserProfileCompleteEvent);
  }

  FutureOr<void> _handleInit(
      UserInitEvent event, Emitter<UserState> emit) async {
    try {
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

      emit(UserCompleteState(
        id: userDetails.userId,
        email: userDetails.username,
        username: username,
        userMfa: mfaStatus,
      ));
    } on ApplicationException catch (_) {
      emit(UserAuthErrorState());
    } catch (e) {
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
}
