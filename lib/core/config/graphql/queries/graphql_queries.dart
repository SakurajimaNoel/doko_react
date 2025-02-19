import 'package:doko_react/core/config/graphql/graphql_constants.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/query/query_helper.dart';

class GraphqlQueries {
  // get user query and variables for self
  static String getUserById() {
    return """
      query Users(\$where: UserWhere) {
        users(where: \$where) {
          id
          username
          name
          profilePicture
        }
      }
    """;
  }

  static Map<String, dynamic> getUserByIdVariables(String userId) {
    return {
      "where": {
        "id_EQ": userId,
      },
    };
  }

  // get user by username
  static String getUserByUsername() {
    return """
      query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        users(where: \$where) {
          username
          name
          id
          profilePicture
          friendsConnection(where: \$friendsConnectionWhere2) {
            edges {
              properties {
                requestedBy
                addedOn
                status
              }
            }
          }
        }
      }
    """;
  }

  static Map<String, dynamic> getUserByUsernameVariables(
    String username, {
    required String currentUser,
  }) {
    return {
      "where": {
        "username_EQ": username,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": currentUser,
        }
      }
    };
  }

  // check username query and variables
  static String checkUsername() {
    return """
      query Users(\$where: UserWhere) {
        users(where: \$where) {
          id
        }
      }
    """;
  }

  static Map<String, dynamic> checkUsernameVariables(String username) {
    return {
      "where": {
        "username_EQ": username,
      }
    };
  }

  static String getCompleteUser() {
    return '''
      query Users(\$where: UserWhere, \$friendsAggregateWhere2: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$limit: Int, \$first: Int, \$postsConnectionWhere2: PostWhere, \$sort: [PostSort!], \$likedByWhere2: UserWhere) {
        users(where: \$where, limit: \$limit) {
          id
          username
          name
          profilePicture
          createdOn
          dob
          bio
          postsAggregate {
            count
          }
          friendsAggregate(where: \$friendsAggregateWhere2) {
            count
          }
          pollsAggregate {
            count
          }
          discussionsAggregate {
            count
          }
          friendsConnection(where: \$friendsConnectionWhere2) {
            edges {
              properties {
                addedOn
                requestedBy
                status
              }
            }
          }
        }
        postsConnection(first: \$first, where: \$postsConnectionWhere2, sort: \$sort) {
          pageInfo {
            endCursor
            hasNextPage
          }
          edges {
            node {
              id
              createdOn
              content
              caption
              createdBy {
                username
              }
              commentsConnection {
                totalCount
              }
              likedByConnection {
                totalCount
              }
              likedBy(where: \$likedByWhere2) {
                username
              }
            }
          }
        }
      }
    ''';
  }

  static Map<String, dynamic> getCompleteUserVariables(
    String username, {
    required String currentUsername,
  }) {
    return {
      "where": {
        "username_EQ": username,
      },
      "friendsAggregateWhere2": {
        "friendsConnection_SOME": {
          "edge": {
            "status_EQ": FriendStatus.accepted,
          }
        }
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
      "first": GraphqlConstants.postLimit,
      "postsConnectionWhere2": {
        "createdBy": {
          "username_EQ": username,
        }
      },
      "sort": [
        {
          "createdOn": "DESC",
        }
      ],
      "likedByWhere2": {
        "username_EQ": currentUsername,
      },
    };
  }

  // get user accepted friends by username
  static String getFriendsByUsername(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
       query Users(\$where: UserWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
        users(where: \$where) {
          friendsConnection(first: \$first, sort: \$sort, where: \$friendsConnectionWhere2) {
            pageInfo {
              endCursor
              hasNextPage
            }
            edges {
              node {
                id
                username
                name
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    properties {
                      requestedBy
                      status
                      addedOn
                    }
                  }
                }
              }
            }
          }
        }
      }
      """;
    }

    return """
       query Users(\$where: UserWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere, \$after: String) {
        users(where: \$where) {
          friendsConnection(first: \$first, sort: \$sort, where: \$friendsConnectionWhere2, after: \$after) {
            pageInfo {
              endCursor
              hasNextPage
            }
            edges {
              node {
                id
                username
                name
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    properties {
                      requestedBy
                      status
                      addedOn
                    }
                  }
                }
              }
            }
          }
        }
      }
    """;
  }

  static Map<String, dynamic> getFriendsByUsernameVariables(
    String username, {
    String? cursor,
    required String currentUsername,
  }) {
    if (cursor == null || cursor.isEmpty) {
      return {
        "where": {
          "username_EQ": username,
        },
        "first": GraphqlConstants.friendLimit,
        "sort": [
          {
            "edge": {
              "addedOn": "DESC",
            }
          }
        ],
        "friendsConnectionWhere2": {
          "edge": {
            "status_EQ": FriendStatus.accepted,
          }
        },
        "friendsConnectionWhere3": {
          "node": {
            "username_EQ": currentUsername,
          }
        },
      };
    }

    return {
      "where": {
        "username_EQ": username,
      },
      "after": cursor,
      "first": GraphqlConstants.friendLimit,
      "sort": [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
      "friendsConnectionWhere2": {
        "edge": {
          "status_EQ": FriendStatus.accepted,
        }
      },
      "friendsConnectionWhere3": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
    };
  }

  // get user posts by username
  static String getUserPostsByUsername() {
    return """
        query Posts(\$after: String, \$sort: [PostSort!], \$first: Int, \$where: PostWhere, \$likedByWhere2: UserWhere) {
          postsConnection(after: \$after, sort: \$sort, first: \$first, where: \$where) {
            pageInfo {
              endCursor
              hasNextPage
            }
            edges {
              node {
                id
                createdOn
                content
                caption
                createdBy {
                  username
                }
                likedBy(where: \$likedByWhere2) {
                  username
                }
                likedByConnection {
                  totalCount
                }
                commentsConnection {
                  totalCount
                }
              }
            }
          }
        }
        """;
  }

  static Map<String, dynamic> getUserPostsByUsernameVariables(
    String username, {
    required String cursor,
    required String currentUsername,
  }) {
    return {
      "where": {
        "createdBy": {
          "username_EQ": username,
        }
      },
      "first": GraphqlConstants.postLimit,
      "after": cursor,
      "sort": [
        {
          "createdOn": "DESC",
        }
      ],
      "likedByWhere2": {
        "username_EQ": currentUsername,
      },
    };
  }

// get user pending friends outgoing
  static String getPendingOutgoingFriendsByUsername(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
        query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!]) {
          users(where: \$where) {
            friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort) {
              pageInfo {
                endCursor
                hasNextPage
              }
              edges {
                node {
                  id
                  username
                  name
                  profilePicture
                  friendsConnection(where: \$friendsConnectionWhere3) {
                    edges {
                      properties {
                        requestedBy
                        status
                        addedOn
                      }
                    }
                  }
                }
              }
            }
          }
        }
    """;
    }

    return """
      query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$after: String) {
        users(where: \$where) {
          friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort, after: \$after) {
            pageInfo {
              endCursor
              hasNextPage
            }
            edges {
              node {
                id
                username
                name
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    properties {
                      requestedBy
                      status
                      addedOn
                    }
                  }
                }
              }
            }
          }
        }
      }
    """;
  }

  static Map<String, dynamic> getPendingOutgoingFriendsByUsernameVariables(
    String username, {
    String? cursor,
  }) {
    if (cursor == null || cursor.isEmpty) {
      return {
        "where": {
          "username_EQ": username,
        },
        "friendsConnectionWhere2": {
          "edge": {
            "status_EQ": FriendStatus.pending,
            "requestedBy_EQ": username,
          }
        },
        "friendsConnectionWhere3": {
          "node": {
            "username_EQ": username,
          }
        },
        "first": GraphqlConstants.friendLimit,
        "sort": [
          {
            "edge": {
              "addedOn": "DESC",
            }
          }
        ],
      };
    }

    return {
      "where": {
        "username_EQ": username,
      },
      "friendsConnectionWhere2": {
        "edge": {
          "status_EQ": FriendStatus.pending,
          "requestedBy_EQ": username,
        }
      },
      "friendsConnectionWhere3": {
        "node": {
          "username_EQ": username,
        }
      },
      "after": cursor,
      "first": GraphqlConstants.friendLimit,
      "sort": [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
    };
  }

  // get user pending friends incoming
  static String getPendingIncomingFriendsByUsername(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
       query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!]) {
        users(where: \$where) {
          friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort) {
            pageInfo {
              endCursor
              hasNextPage
            }
            edges {
              node {
                id
                username
                name
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    properties {
                      requestedBy
                      status
                      addedOn
                    }
                  }
                }
              }
            }
          }
        }
      }
    """;
    }

    return """
      query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$after: String) {
        users(where: \$where) {
          friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort, after: \$after) {
            pageInfo {
              endCursor
              hasNextPage
            }
            edges {
              node {
                id
                username
                name
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    properties {
                      requestedBy
                      status
                      addedOn
                    }
                  }
                }
              }
            }
          }
        }
      }
     """;
  }

  static Map<String, dynamic> getPendingIncomingFriendsByUsernameVariables(
    String username, {
    String? cursor,
  }) {
    if (cursor == null || cursor.isEmpty) {
      return {
        "where": {
          "username_EQ": username,
        },
        "friendsConnectionWhere2": {
          "edge": {
            "status_EQ": FriendStatus.pending,
            "NOT": {
              "requestedBy_EQ": username,
            }
          }
        },
        "friendsConnectionWhere3": {
          "node": {
            "username_EQ": username,
          }
        },
        "first": GraphqlConstants.friendLimit,
        "sort": [
          {
            "edge": {
              "addedOn": "DESC",
            }
          }
        ],
      };
    }

    return {
      "where": {
        "username_EQ": username,
      },
      "friendsConnectionWhere2": {
        "edge": {
          "status_EQ": FriendStatus.pending,
          "NOT": {
            "requestedBy_EQ": username,
          }
        }
      },
      "friendsConnectionWhere3": {
        "node": {
          "username_EQ": username,
        }
      },
      "after": cursor,
      "first": GraphqlConstants.friendLimit,
      "sort": [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
    };
  }

  // search user based on username or name
  static String searchUserByUsernameOrName() {
    return '''
      query Users(\$where: UserWhere, \$limit: Int, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        users(where: \$where, limit: \$limit) {
          id
          name
          profilePicture
          username
          friendsConnection(where: \$friendsConnectionWhere2) {
            edges {
              properties {
                requestedBy
                status
                addedOn
              }
            }
          }
        }
      }
    ''';
  }

  static Map<String, dynamic> searchUserByUsernameOrNameVariables(
    String query, {
    required String username,
  }) {
    return {
      "where": {
        "OR": [
          {
            "username_MATCHES": caseInsensitiveQuery(query),
          },
          {
            "name_MATCHES": caseInsensitiveQuery(query),
          }
        ]
      },
      "limit": GraphqlConstants.generalSearchLimit,
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      }
    };
  }

  // search user friends based on username or name
  static String searchUserFriendsByUsernameOrName() {
    return '''
    query Users(\$where: UserWhere, \$first: Int, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
      users(where: \$where) {
        friendsConnection(first: \$first, where: \$friendsConnectionWhere2) {
          edges {
            node {
              id
              username
              name
              profilePicture
              friendsConnection(where: \$friendsConnectionWhere3) {
                edges {
                  properties {
                    requestedBy
                    addedOn
                    status
                  }
                }
              }
            }
          }
        }
      }
    }
    ''';
  }

  static Map<String, dynamic> searchUserFriendsByUsernameOrNameVariables(
    String username, {
    required String currentUsername,
    required String query,
  }) {
    return {
      "where": {
        "username_EQ": username,
      },
      "first": GraphqlConstants.friendSearchLimit,
      "friendsConnectionWhere2": {
        "edge": {
          "status_EQ": FriendStatus.accepted,
        },
        "node": {
          "OR": [
            {
              "name_MATCHES": caseInsensitiveQuery(query),
            },
            {
              "username_MATCHES": caseInsensitiveQuery(query),
            },
          ],
        }
      },
      "friendsConnectionWhere3": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
    };
  }

  // search user friends by username for comment mention
  static String searchUsersByUsername() {
    return '''
      query Users(\$where: UserWhere, \$limit: Int, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        users(where: \$where, limit: \$limit) {
          id
          name
          profilePicture
          username
          friendsConnection(where: \$friendsConnectionWhere2) {
            edges {
              properties {
                requestedBy
                status
                addedOn
              }
            }
          }
        }
      }
    ''';
  }

  static Map<String, dynamic> searchUsersByUsernameVariables(
    String username, {
    required String query,
  }) {
    return {
      "where": {
        "username_MATCHES": caseInsensitiveQuery(query),
      },
      "limit": GraphqlConstants.friendSearchCommentLimit,
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      }
    };
  }

  // post by id
  static String getCompletePostById() {
    return """
     query Posts(\$where: PostWhere, \$likedByWhere2: UserWhere, \$first: Int, \$likedByWhere3: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
      posts(where: \$where) {
        id
        createdOn
        content
        caption
        createdBy {
          id
          username
          name
          profilePicture
          friendsConnection(where: \$friendsConnectionWhere2) {
            edges {
              properties {
                addedOn
                requestedBy
                status
              }
            }
          }
        }
        likedBy(where: \$likedByWhere2) {
          username
        }   
        likedByConnection {
          totalCount
        }
        commentsConnection(first: \$first) {
          totalCount
          pageInfo {
            endCursor
            hasNextPage
          }
          edges {
            node {
              id
              createdOn
              media
              content
              mentions {
                username
              }
              likedBy(where: \$likedByWhere3) {
                username
              }
              likedByConnection {
                totalCount
              }
              commentsConnection {
                totalCount
              }
              commentBy {
                id
                username
                profilePicture
                name
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    properties {
                      addedOn
                      requestedBy
                      status
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getCompletePostByIdVariables(
    String postId, {
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": postId,
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "first": GraphqlConstants.commentLimit,
      "likedByWhere3": {
        "username_EQ": username,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "friendsConnectionWhere3": {
        "node": {
          "username_EQ": username,
        }
      },
    };
  }

  // get comments
  static String getComments({
    String? cursor,
  }) {
    if (cursor == null || cursor.isEmpty) {
      return '''
        query CommentsConnection(\$first: Int, \$where: CommentWhere, \$likedByWhere2: UserWhere, \$sort: [CommentSort!], \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
          commentsConnection(first: \$first, where: \$where, sort: \$sort) {
            pageInfo {
              endCursor
              hasNextPage
            }
            edges {
              node {
                id
                createdOn
                media
                content
                mentions {
                  username
                }
                commentsConnection {
                  totalCount
                }
                likedByConnection {
                  totalCount
                }
                likedBy(where: \$likedByWhere2) {
                  username
                }
                replyOn {
                  id
                }
                commentBy {
                  id
                  username
                  profilePicture
                  name
                   friendsConnection(where: \$friendsConnectionWhere2) {
                    edges {
                      properties {
                        addedOn
                        requestedBy
                        status
                      }
                    }
                  }
                }
              }
            }
          }
        }
    ''';
    }

    return '''
      query CommentsConnection(\$first: Int, \$where: CommentWhere, \$likedByWhere2: UserWhere, \$sort: [CommentSort!], \$after: String, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        commentsConnection(first: \$first, where: \$where, sort: \$sort, after: \$after) {
          pageInfo {
            endCursor
            hasNextPage
          }
          edges {
            node {
              id
              createdOn
              media
              content
              mentions {
                username
              }
              commentsConnection {
                totalCount
              }
              likedByConnection {
                totalCount
              }
              likedBy(where: \$likedByWhere2) {
                username
              }
              replyOn {
                id
              }
              commentBy {
                id
                username
                profilePicture
                name
                 friendsConnection(where: \$friendsConnectionWhere2) {
                  edges {
                    properties {
                      addedOn
                      requestedBy
                      status
                    }
                  }
                }
              }
            }
          }
        }
      }
    ''';
  }

  static Map<String, dynamic> getCommentsVariable(
    String nodeId, {
    String? cursor,
    required DokiNodeType nodeType,
    required String username,
    bool latestFirst = true,
  }) {
    String connectionNode = nodeType.nodeName;
    String sort = latestFirst ? "DESC" : "ASC";

    if (cursor == null || cursor.isEmpty) {
      return {
        "first": GraphqlConstants.commentLimit,
        "where": {
          "commentOn": {
            connectionNode: {
              "id_EQ": nodeId,
            }
          }
        },
        "likedByWhere2": {
          "username_EQ": username,
        },
        "sort": [
          {
            "createdOn": sort,
          }
        ],
        "friendsConnectionWhere2": {
          "node": {
            "username_EQ": username,
          }
        },
      };
    }

    return {
      "first": GraphqlConstants.commentLimit,
      "where": {
        "commentOn": {
          connectionNode: {
            "id_EQ": nodeId,
          }
        }
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "after": cursor,
      "sort": [
        {
          "createdOn": sort,
        }
      ],
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
    };
  }

  // post for preview in chat
  static String getPostById() {
    return """
      query Posts(\$where: PostWhere, \$likedByWhere2: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        posts(where: \$where) {
          id
          createdOn
          content
          caption
          createdBy {
            id
            name
            username
            profilePicture
            friendsConnection(where: \$friendsConnectionWhere2) {
              edges {
                properties {
                  addedOn
                  requestedBy
                  status
                }
              }
            }
          }
          likedByConnection {
            totalCount
          }
          commentsConnection {
            totalCount
          }
          likedBy(where: \$likedByWhere2) {
            username
          }
        }
      }      
    """;
  }

  static Map<String, dynamic> getPostByIdVariables(
    String postId, {
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": postId,
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      }
    };
  }

  // get comment by id
  static String getCommentById() {
    return """
    query Comments(\$where: CommentWhere, \$likedByWhere2: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
      comments(where: \$where) {
        id
        createdOn
        media
        content
        mentions {
          username
        }
        commentsConnection {
          totalCount
        }
        likedByConnection {
          totalCount
        }
        likedBy(where: \$likedByWhere2) {
          username
        }
        replyOn {
          id
        }
        commentBy {
          id
          name
          username
          profilePicture
          friendsConnection(where: \$friendsConnectionWhere2) {
            edges {
              properties {
                addedOn
                requestedBy
                status
              }
            }
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getCommentByIdVariables({
    required String commentId,
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": commentId,
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      }
    };
  }

  // complete comment with replies
  static String getCompleteCommentById() {
    return """
    query Comments(\$where: CommentWhere, \$likedByWhere2: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [CommentCommentsConnectionSort!]) {
      comments(where: \$where) {
        id
        createdOn
        media
        content
        mentions {
          username
        }
        likedByConnection {
          totalCount
        }
        likedBy(where: \$likedByWhere2) {
          username
        }
        replyOn {
          id 
        }
        commentBy {
          id
          username
          name
          profilePicture
          friendsConnection(where: \$friendsConnectionWhere2) {
            edges {
              properties {
                addedOn
                requestedBy
                status
              }
            }
          }
        }
        commentsConnection(first: \$first, sort: \$sort) {
          totalCount
          pageInfo {
            endCursor
            hasNextPage
          }
          edges {
            node {
              id
              createdOn
              media
              content
              mentions {
                username
              }
              likedByConnection {
                totalCount
              }
              likedBy(where: \$likedByWhere2) {
                username
              }
              replyOn {
                id
              }
              commentsConnection {
                totalCount
              }
              commentBy {
                id
                username
                name
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere2) {
                  edges {
                    properties {
                      addedOn
                      requestedBy
                      status
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getCompleteCommentByIdVariables(
    String commentId, {
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": commentId,
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "first": GraphqlConstants.commentLimit,
      "sort": [
        {
          "node": {
            "createdOn": "ASC",
          }
        }
      ],
    };
  }
}
