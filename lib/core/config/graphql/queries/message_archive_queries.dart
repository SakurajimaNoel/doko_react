import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/config/graphql/graphql_constants.dart';

class MessageArchiveQueries {
  static String getUserInbox(String cursor) {
    if (cursor.isEmpty) {
      return """
      query ListMessageInbox(\$user: String!, \$limit: Int, \$sortDirection: ModelSortDirection) {
        messageInboxesByUserAndCreatedAt(user: \$user, limit: \$limit, sortDirection: \$sortDirection) {
          nextToken
          items {
            user
            inboxUser
            unread
            displayText
            createdAt
          }
        }
      }
      """;
    }

    return """
    query ListMessageInbox(\$user: String!, \$limit: Int, \$sortDirection: ModelSortDirection, \$nextToken: String) {
      messageInboxesByUserAndCreatedAt(user: \$user, limit: \$limit, sortDirection: \$sortDirection, nextToken: \$nextToken) {
        nextToken
        items {
          user
          inboxUser
          unread
          displayText
          createdAt
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getUserInboxVariables({
    required String username,
    required String cursor,
  }) {
    if (cursor.isEmpty) {
      return {
        "user": username,
        "limit": GraphqlConstants.nodeLimit,
        "sortDirection": "DESC",
      };
    }

    return {
      "user": username,
      "limit": GraphqlConstants.nodeLimit,
      "sortDirection": "DESC",
      "nextToken": cursor,
    };
  }

  // archive messages
  static String getMessageArchive(String cursor) {
    if (cursor.isEmpty) {
      return """
      query ListMessageArchives(\$archive: String, \$limit: Int, \$sortDirection: ModelSortDirection, \$filter: ModelMessageArchiveFilterInput) {
        listMessageArchives(archive: \$archive, limit: \$limit, sortDirection: \$sortDirection, filter: \$filter) {
          nextToken
          items {
            archive
            from
            to
            subject
            body
            createdAt
            deleted
            forwarded
            edited
            id
            replyFor
          }
        }
      }
      """;
    }

    return """
    query ListMessageArchives(\$archive: String, \$limit: Int, \$sortDirection: ModelSortDirection, \$nextToken: String, \$filter: ModelMessageArchiveFilterInput) {
      listMessageArchives(archive: \$archive, limit: \$limit, sortDirection: \$sortDirection, nextToken: \$nextToken, filter: \$filter) {
        nextToken
        items {
          archive
          from
          to
          subject
          body
          createdAt
          deleted
          forwarded
          edited
          id
          replyFor
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getMessageArchiveVariables({
    required String archive,
    required String cursor,
  }) {
    if (cursor.isEmpty) {
      return {
        "archive": archive,
        "limit": 50,
        "sortDirection": "DESC",
        "filter": {
          "deleted": {
            "eq": false,
          }
        },
      };
    }

    return {
      "archive": archive,
      "limit": 50,
      "sortDirection": "DESC",
      "nextToken": cursor,
      "filter": {
        "deleted": {
          "eq": false,
        }
      },
    };
  }

  /// lost messages on disconnect
  static String getUserLostMessages() {
    return """
    query Items(\$filter: ModelMessageArchiveFilterInput) {
      listMessageArchives(filter: \$filter) {
        items {
          archive
          from
          to
          subject
          body
          createdAt
          deleted
          forwarded
          edited
          id
          replyFor
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getUserLostMessagesVariables({
    required String username,
    required DateTime after,
  }) {
    return {
      "filter": {
        "and": [
          {
            "updatedAt": {
              "ge": TemporalDateTime(after).toString(),
            }
          },
          {
            "or": [
              {
                "from": {
                  "eq": username,
                },
              },
              {
                "to": {
                  "eq": username,
                }
              }
            ]
          }
        ]
      }
    };
  }
}
