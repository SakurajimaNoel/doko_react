import 'package:doko_react/core/config/graphql/mutations/graphql_mutations.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:doko_react/core/global/storage/storage.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:graphql/client.dart';

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
        throw const ApplicationException(
          reason: "Problem checking username availability.",
        );
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

  Future<bool> completeUserProfile(
      CompleteProfileInput userDetails, String bucketPath) async {
    try {
      // upload profile picture to bucket
      await uploadFileToAWSByPath(userDetails.profilePath, bucketPath);

      // create node in graph
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.completeUserProfile()),
          variables: GraphqlMutations.completeUserProfileVariables(
            userDetails,
            bucketPath,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Can't complete user profile right now.",
        );
      }

      // check if user data is present
      List res = result.data?["createUsers"]["users"];
      if (res.isEmpty) {
        throw const ApplicationException(
            reason: "Something went wrong when completing user profile.");
      }

      final UserEntity currentUser = await UserEntity.createEntity(map: res[0]);
      final UserGraph graph = UserGraph();
      String key = generateUserNodeKey(currentUser.username);

      graph.addEntity(key, currentUser);

      // add to cognito
      await addUsername(userDetails.username);
      await refreshAuthSession();

      // if all done return true
      return true;
    } catch (_) {
      // clean up if profile can't be completed
      deleteFileFromAWSByPath(bucketPath);
      rethrow;
    }
  }
}
