import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../model/user_model.dart';

class UserResponse {
  final ResponseStatus status;
  final UserModel? user;

  const UserResponse({
    required this.status,
    this.user,
  });
}

class UsernameResponse {
  final ResponseStatus status;
  final bool available;

  const UsernameResponse({
    required this.status,
    required this.available,
  });
}

class UserGraphqlService {
  static GraphqlConfig config = GraphqlConfig();
  GraphQLClient client = config.clientToQuery();

  Future<UserResponse> getUser(String id) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          document: gql("""
        query Query(\$where: UserWhere) {
          users(where: \$where) {
            id
            name
            username
            profilePicture
          }
        }
        """),
          variables: {
            "where": {
              "id": id,
            }
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const UserResponse(
          status: ResponseStatus.success,
        );
      }

      UserModel user = UserModel.createModel(map: res[0]);
      return UserResponse(
        status: ResponseStatus.success,
        user: user,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UserResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<UsernameResponse> checkUsername(String username) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          document: gql("""
          query Query(\$where: UserWhere) {
            users(where: \$where) {
              id
            }
          }
        """),
          variables: {
            "where": {
              "username": username,
            }
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const UsernameResponse(
          status: ResponseStatus.success,
          available: true,
        );
      }

      return const UsernameResponse(
        status: ResponseStatus.success,
        available: false,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UsernameResponse(
        status: ResponseStatus.error,
        available: false,
      );
    }
  }

  Future<UserResponse> completeUserProfile(String id, String username,
      String email, DateTime dob, String name, String profilePicture) async {
    try {
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql("""
        mutation Mutation(\$input: [UserCreateInput!]!) {
          createUsers(input: \$input) {
            info {
              nodesCreated
            }
          }
        }        
        """),
          variables: {
            "input": [
              {
                "id": id,
                "username": username,
                "email": email,
                "dob": DisplayText.date(dob),
                "name": name,
                "profilePicture": profilePicture,
              }
            ]
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      return const UserResponse(
        status: ResponseStatus.success,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UserResponse(
        status: ResponseStatus.error,
      );
    }
  }
}
