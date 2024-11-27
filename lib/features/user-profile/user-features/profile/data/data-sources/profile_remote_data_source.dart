import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  // todo: improve this function
  Future<bool> getCompleteUserDetails(
    String username, {
    required String currentUsername,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getCompleteUser()),
          variables: GraphqlQueries.getCompleteUserVariables(
            username,
            currentUsername: currentUsername,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem fetching data source.");
      }

      List? res = result.data?["users"];
      Map postRes = result.data?["postsConnection"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(reason: "User doesn't exist.");
      }

      // add in graph
      UserGraph graph = UserGraph();

      CompleteUserEntity user = await CompleteUserEntity.createEntity(
        map: res[0],
      );
      String key = generateUserNodeKey(user.username);
      graph.addEntity(key, user);

      PageInfo info = PageInfo.createEntity(map: postRes["pageInfo"]);
      List postList = postRes["edges"];

      var postFutures = (postList)
          .map((post) => PostEntity.createEntity(map: post["node"]))
          .toList();

      List<PostEntity> posts = await Future.wait(postFutures);
      graph.addPostEntityListToUser(
        user.username,
        newPosts: posts,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      safePrint(e.toString());
      rethrow;
    }
  }
}
