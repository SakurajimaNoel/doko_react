import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart' hide Emitter;
import 'package:bloc/bloc.dart';
import 'package:doko_react/archive/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:equatable/equatable.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoading()) {
    on<UserInitEvent>(_handleInit);
    on<UserAuthenticatedEvent>(_handeUserFetch);
  }

  FutureOr<void> _handleInit(
      UserInitEvent event, Emitter<UserState> emit) async {
    try {
      safePrint("init event");
      // this will trigger amplify hub listener
      final result = await Amplify.Auth.fetchAuthSession();

      if (result.isSignedIn) {
        add(UserAuthenticatedEvent());
        return;
      }

      emit(UserUnauthenticated());
    } on AuthException catch (e) {
      emit(UserUnauthenticated());
    } catch (e) {
      emit(UserAuthError());
    }
  }

  FutureOr<void> _handeUserFetch(
      UserAuthenticatedEvent event, Emitter<UserState> emit) async {
    try {
      safePrint("user fetch event");
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
        emit(UserIncomplete(
          id: userDetails.userId,
          email: userDetails.username,
        ));
        return;
      }

      String username = res[0]["username"];
      bool mfaStatus = await getUserMFAStatus();

      emit(UserComplete(
        id: userDetails.userId,
        email: userDetails.username,
        username: username,
        userMfa: mfaStatus,
      ));
    } on AuthException catch (e) {
      emit(UserAuthError());
    } catch (e) {
      emit(UserGraphError());
    }
  }
}
