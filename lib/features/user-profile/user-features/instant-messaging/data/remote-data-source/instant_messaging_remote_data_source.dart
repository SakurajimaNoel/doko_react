import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/config/graphql/queries/message_archive_queries.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/archive-query-input/archive_query_input.dart';
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
      QueryResult result = await messageArchiveClient.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(MessageArchiveQueries.getUserInbox(details.cursor)),
          variables: MessageArchiveQueries.getUserInboxVariables(
            username: details.username,
            cursor: details.cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem getting user inbox data.",
        );
      }

      Map inboxData = result.data?["messageInboxesByUserAndCreatedAt"];
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

  Future<bool> getNodeDetailsForMessageArchive({
    required String username,
    required List<String> contentIds,
    required List<String> users,
  }) async {
    try {
      if (contentIds.isEmpty && users.isEmpty) return true;

      QueryResult result = await apiClient.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getNodeDetailsForMessageArchive()),
          variables: GraphqlQueries.getNodeDetailsForMessageArchiveVariables(
            username: username,
            users: users,
            contentIds: contentIds,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Error getting node details.");
      }

      List? userDetails = result.data?["users"];
      List? contentDetails = result.data?["contents"];

      if (userDetails != null && userDetails.isNotEmpty) {
        var userFutures = (userDetails)
            .map((user) => UserEntity.createEntity(
                  map: user,
                ))
            .toList();
        List<UserEntity> userEntities = await Future.wait(userFutures);
        graph.addUserSearchEntry(userEntities);
      }

      if (contentDetails != null && contentDetails.isNotEmpty) {
        var contentFuture = (contentDetails).map((contentMap) {
          String typename = contentMap["__typename"];
          DokiNodeType node = DokiNodeType.fromTypename(typename);

          return node.entityGenerator(
            map: contentMap,
          );
        }).toList();

        List<GraphEntity> content = await Future.wait(contentFuture);
        for (var item in content) {
          graph.addEntity(item.getNodeKey(), item);
        }
      }

      return true;
    } catch (_) {
      // just ignore error for this one
      return true;
    }
  }

  Future<bool> getUserArchive(ArchiveQueryInput details) async {
    try {
      QueryResult result = await messageArchiveClient.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document:
              gql(MessageArchiveQueries.getMessageArchive(details.cursor)),
          variables: MessageArchiveQueries.getMessageArchiveVariables(
            archive: details.getArchive(),
            cursor: details.cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem getting user messages.",
        );
      }

      Map archiveData = result.data?["listMessageArchives"];
      String nextToken = archiveData["nextToken"] ?? "";
      PageInfo info = PageInfo(
        endCursor: nextToken,
        hasNextPage: nextToken.isNotEmpty,
      );
      List archiveList = archiveData["items"];

      List<String> archiveItems = [];
      List<String> contentIds = [];
      List<String> users = [];

      for (var item in archiveList) {
        MessageEntity entity = MessageEntity.createEntity(item);
        String messageKey = generateMessageKey(entity.message.id);
        graph.addEntity(messageKey, entity);

        if (entity.message.subject.value.startsWith("doki@")) {
          /// graph node, check if not exists
          final node = DokiNodeType.fromMessageSubject(entity.message.subject);
          String body = entity.message.body;
          String nodeKey = node.keyGenerator(body);
          if (!graph.containsKey(nodeKey)) {
            if (node == DokiNodeType.user) {
              users.add(body);
            } else {
              contentIds.add(body);
            }
          }
        }

        archiveItems.add(messageKey);
      }
      graph.addArchiveItems(
        archive: details.username,
        items: archiveItems,
        info: info,
      );

      return await getNodeDetailsForMessageArchive(
        username: details.currentUser,
        contentIds: contentIds,
        users: users,
      );
    } catch (_) {
      rethrow;
    }
  }
}
