import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CompleteProfileRemoteDataSource {
  const CompleteProfileRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  Future<bool> checkUsernameAvailability(UsernameInput username) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.checkUsername()),
          variables: GraphqlQueries.checkUsernameVariables(username.username),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem fetching data source.");
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return true;
      }
      return false;
    } catch (_) {
      rethrow;
    }
  }
}
