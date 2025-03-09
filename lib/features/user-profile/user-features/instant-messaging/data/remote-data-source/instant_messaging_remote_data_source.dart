import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/config/graphql/queries/message_archive_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';
import 'package:graphql/client.dart';

class InstantMessagingRemoteDataSource {
  InstantMessagingRemoteDataSource({
    required this.apiClient,
    required this.messageArchiveClient,
  });

  final GraphQLClient apiClient;
  final GraphQLClient messageArchiveClient;
  final UserGraph graph = UserGraph();

  Future<bool> _getUserDetails(List<String> users, String username) async {
    try {
      QueryResult result = await apiClient.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getUserDetailsForInbox()),
          variables:
              GraphqlQueries.getUserDetailsForInboxVariables(users, username),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Error getting user details.");
      }
      List? res = result.data?["users"];
      if (res == null || res.isEmpty) {
        // no users found this should not occur
        return true;
      }

      var userFutures = (res)
          .map((user) => UserEntity.createEntity(
                map: user,
              ))
          .toList();
      List<UserEntity> userEntities = await Future.wait(userFutures);
      graph.addUserSearchEntry(userEntities);

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> getUserInbox(InboxQueryInput details) async {
    try {
      // first fetch user inbox
      QueryResult inboxResult = await messageArchiveClient.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(MessageArchiveQueries.getUserInbox(details.cursor)),
          variables: MessageArchiveQueries.getUserInboxVariables(
            username: details.username,
            cursor: details.cursor,
          ),
        ),
      );

      if (inboxResult.hasException) {
        throw const ApplicationException(
          reason: "Problem getting user inbox data.",
        );
      }

      Map inboxData = inboxResult.data?["messageInboxesByUserAndCreatedAt"];
      String nextToken = inboxData["nextToken"] ?? "";
      PageInfo info = PageInfo(
        endCursor: nextToken,
        hasNextPage: nextToken.isNotEmpty,
      );
      List inboxList = inboxData["items"];

      // inbox item key
      List<String> inboxItems = [];
      List<String> usersToFetch = [];

      for (var item in inboxList) {
        InboxItemEntity entity = InboxItemEntity.createEntity(item);
        String inboxItemKey = generateInboxItemKey(entity.user);
        graph.addEntity(inboxItemKey, entity);

        inboxItems.add(inboxItemKey);

        // check if user exists
        String userKey = generateUserNodeKey(entity.user);
        if (!graph.containsKey(userKey)) {
          usersToFetch.add(entity.user);
        }
      }

      graph.addInboxItems(inboxItems, info);
      if (usersToFetch.isEmpty) return true;

      // fetch users
      return _getUserDetails(usersToFetch, details.username);
    } catch (_) {
      rethrow;
    }
  }
}
