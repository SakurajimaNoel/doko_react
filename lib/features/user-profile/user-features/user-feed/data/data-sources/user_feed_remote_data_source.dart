import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/input/user_feed_input.dart';
import 'package:graphql/client.dart';

class UserFeedRemoteDataSource {
  const UserFeedRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  Future<bool> fetchUserFeed(UserFeedInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.userFeed()),
          variables: GraphqlQueries.userFeedVariables(
            username: details.username,
            cursor: details.cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem getting user feed data.",
        );
      }

      Map contentRes = result.data?["contentsConnection"];
      // add in graph
      UserGraph graph = UserGraph();
      PageInfo info = PageInfo.createEntity(map: contentRes["pageInfo"]);
      List contentList = contentRes["edges"];

      List<String> items = [];
      var contentFuture = (contentList).map((content) {
        var contentMap = content["node"];
        String id = contentMap["id"];

        String typename = contentMap["__typename"];
        DokiNodeType node = DokiNodeType.fromTypename(typename);
        items.add(node.keyGenerator(id));

        return node.entityGenerator(
          map: contentMap,
        );
      }).toList();

      var content = await Future.wait(contentFuture);
      for (var item in content) {
        graph.addEntity(item.getNodeKey(), item);
      }

      final String userFeedKey = generateUserFeedKey();
      var node = graph.getValueByKey(userFeedKey);

      if (node is! Nodes || details.cursor.isEmpty) {
        graph.addEntity(userFeedKey, Nodes.empty());
        node = graph.getValueByKey(userFeedKey)! as Nodes;
      }
      node.updatePageInfo(info);
      node.addEntityItems(items);

      return true;
    } catch (_) {
      rethrow;
    }
  }
}
