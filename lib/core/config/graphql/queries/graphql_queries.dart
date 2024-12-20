import 'package:doko_react/core/config/graphql/queries/graphql_query_constants.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/helpers/query/query_helper.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';

class CompleteUserProfileVariables {
  final String id;
  final String username;
  final String email;
  final DateTime dob;
  final String name;
  final String profilePicture;

  const CompleteUserProfileVariables({
    required this.id,
    required this.username,
    required this.email,
    required this.dob,
    required this.name,
    required this.profilePicture,
  });
}

class GraphqlQueries {
  // get user query and variables
  static String getUser() {
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

  static Map<String, dynamic> getUserVariables(String userId) {
    return {
      "where": {
        "id_EQ": userId,
      },
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

  // complete user profile query and variables
  static String completeUserProfile() {
    return """
      mutation CreateUsers(\$input: [UserCreateInput!]!) {
        createUsers(input: \$input) {
          users { 
            id
            name
            profilePicture
            username            
          }
        }
      }       
    """;
  }

  static Map<String, dynamic> completeUserProfileVariables(
      CompleteProfileInput userDetails, String bucketPath) {
    return {
      "input": [
        {
          "id": userDetails.userId,
          "username": userDetails.username,
          "email": userDetails.email,
          "dob": dateToIsoString(userDetails.dob),
          "name": userDetails.name.trim(),
          "profilePicture": bucketPath,
        }
      ]
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
        "friendsConnection_ALL": {
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
      "first": GraphqlQueryConstants.postLimit,
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
        "first": GraphqlQueryConstants.friendLimit,
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
      "first": GraphqlQueryConstants.friendLimit,
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
      "first": GraphqlQueryConstants.postLimit,
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
        "first": GraphqlQueryConstants.friendLimit,
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
      "first": GraphqlQueryConstants.friendLimit,
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
        "first": GraphqlQueryConstants.friendLimit,
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
      "first": GraphqlQueryConstants.friendLimit,
      "sort": [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
    };
  }

  // update user profile
  static String updateUserProfile() {
    return """
    mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput) {
      updateUsers(where: \$where, update: \$update) {
        users {
          name
          profilePicture
          username
          id
          bio
        }
      }
    }
    """;
  }

  static Map<String, dynamic> updateUserProfileVariables({
    required String username,
    required String name,
    required String bio,
    required String profilePicture,
  }) {
    return {
      "where": {
        "username_EQ": username,
      },
      "update": {
        "name": name.trim(),
        "bio": bio.trim(),
        "profilePicture": profilePicture,
      }
    };
  }

  // user send friend request
  static String userCreateFriendRelation() {
    return """
      mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        updateUsers(where: \$where, update: \$update) {
          users {
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
      } 
    """;
  }

  static Map<String, dynamic> userCreateFriendRelationVariables(
      UserToUserRelationDetails relationDetails) {
    return {
      "where": {
        "username_EQ": relationDetails.initiator,
      },
      "update": {
        "friends": [
          {
            "connect": [
              {
                "edge": {
                  "requestedBy": relationDetails.initiator,
                  "status": FriendStatus.pending,
                },
                "where": {
                  "node": {
                    "username_EQ": relationDetails.participant,
                  }
                }
              }
            ]
          }
        ]
      },
      "friendsConnectionWhere2": {
        "node": {
          // this should be respect to initiator
          "username_EQ": relationDetails.username,
        }
      }
    };
  }

  // user accept friend request
  static String userAcceptFriendRelation() {
    return """
      mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        updateUsers(where: \$where, update: \$update) {
          users {
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
      } 
    """;
  }

  static Map<String, dynamic> userAcceptFriendRelationVariables(
      UserToUserRelationDetails relationDetails) {
    return {
      "where": {
        "username_EQ": relationDetails.initiator,
      },
      "update": {
        "friends": [
          {
            "where": {
              "node": {
                "username_EQ": relationDetails.participant,
              }
            },
            "update": {
              "edge": {
                "status": FriendStatus.accepted,
              }
            }
          }
        ]
      },
      "friendsConnectionWhere2": {
        "node": {
          // this should be respect to initiator
          "username_EQ": relationDetails.currentUsername,
        }
      }
    };
  }

  // user remove friend relation
  static String userRemoveFriendRelation() {
    return """
      mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        updateUsers(where: \$where, update: \$update) {
          users {
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
      }
    """;
  }

  static Map<String, dynamic> userRemoveFriendRelationVariables(
      UserToUserRelationDetails relationDetails) {
    return {
      "where": {
        "username_EQ": relationDetails.initiator,
      },
      "update": {
        "friends": [
          {
            "disconnect": [
              {
                "where": {
                  "node": {
                    "username_EQ": relationDetails.participant,
                  }
                }
              }
            ]
          }
        ]
      },
      "friendsConnectionWhere2": {
        "node": {
          // this should be respect to initiator
          "username_EQ": relationDetails.initiator == relationDetails.username
              ? relationDetails.currentUsername
              : relationDetails.username,
        }
      }
    };
  }

  // use create post
  static String userCreatePost() {
    return """
     mutation CreatePosts(\$input: [PostCreateInput!]!, \$where: UserWhere) {
      createPosts(input: \$input) {
        posts {
          id
          createdOn
          content
          caption
          createdBy {
            username
          }
          likedByConnection {
            totalCount
          }
          commentsConnection {
            totalCount
          }
          likedBy(where: \$where) {
            username
          }
        }
      }
    }       
    """;
  }

  static Map<String, dynamic> userCreatePostVariables(
    String postId, {
    required String username,
    required String caption,
    required List<String> content,
  }) {
    return {
      "input": [
        {
          "id": postId,
          "caption": caption,
          "content": content,
          "likes": 0,
          "createdBy": {
            "connect": {
              "where": {
                "node": {
                  "username_EQ": username,
                },
              },
            },
          },
        },
      ],
      "where": {
        "username_EQ": username,
      }
    };
  }

  // post action like
  static String userAddLikePost() {
    return """
      mutation UpdatePosts(\$where: PostWhere, \$update: PostUpdateInput, \$likedByWhere2: UserWhere) {
        updatePosts(where: \$where, update: \$update) {
          posts {
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
      }
    """;
  }

  static Map<String, dynamic> userAddLikePostVariables(
    String postId, {
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": postId,
      },
      "update": {
        "likedBy": [
          {
            "connect": [
              {
                "where": {
                  "node": {
                    "username_EQ": username,
                  }
                }
              }
            ]
          }
        ]
      },
      "likedByWhere2": {
        "username_EQ": username,
      }
    };
  }

  static String userRemoveLikePost() {
    return """
      mutation UpdatePosts(\$where: PostWhere, \$update: PostUpdateInput, \$likedByWhere2: UserWhere) {
        updatePosts(where: \$where, update: \$update) {
          posts {
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
      }
    """;
  }

  static Map<String, dynamic> userRemoveLikePostVariables(
    String postId, {
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": postId,
      },
      "update": {
        "likedBy": [
          {
            "disconnect": [
              {
                "where": {
                  "node": {
                    "username_EQ": username,
                  }
                }
              }
            ]
          }
        ]
      },
      "likedByWhere2": {
        "username_EQ": username,
      }
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
      "limit": GraphqlQueryConstants.generalSearchLimit,
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
      "first": GraphqlQueryConstants.friendSearchLimit,
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
      "limit": GraphqlQueryConstants.friendSearchCommentLimit,
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      }
    };
  }

  // post by id
  static String getPostById() {
    return """
     query Posts(\$where: PostWhere, \$likedByWhere2: UserWhere, \$first: Int, \$likedByWhere3: UserWhere, \$commentsWhere2: CommentWhere, \$limit: Int, \$likedByWhere4: UserWhere, \$sort: [CommentSort!]) {
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
              }
              comments(where: \$commentsWhere2, limit: \$limit, sort: \$sort) {
                id
                media
                content
                createdOn
                likedByConnection {
                  totalCount
                }
                mentions {
                  username
                }
                likedBy(where: \$likedByWhere4) {
                  username
                }
                commentBy {
                  id
                  username
                  name
                  profilePicture
                }
              }
            }
          }
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
      "first": GraphqlQueryConstants.commentLimit,
      "likedByWhere3": {
        "username_EQ": username,
      },
      "commentsWhere2": {
        "commentBy": {
          "username_EQ": username,
        }
      },
      "limit": 1, // user own comment reply first
      "likedByWhere4": {
        "username_EQ": username,
      },
      "sort": [
        {
          "createdOn": "DESC",
        }
      ]
    };
  }

  // add comment
  static String addComment() {
    return '''
     mutation CreateComments(\$input: [CommentCreateInput!]!, \$where: UserWhere) {
      createComments(input: \$input) {
        comments {
          id
          createdOn
          media
          content
          mentions {
            username
          }
          commentBy {
            id
            username
            name
            profilePicture
          }
          likedByConnection {
            totalCount
          }
          commentsConnection {
            totalCount
          }
          likedBy(where: \$where) {
            username
          }
        }
      }
    }
    ''';
  }

  static Map<String, dynamic> addCommentVariables(
      CommentCreateInput commentInput) {
    String commentOnNode =
        commentInput.targetNode == CommentTarget.comment ? "Comment" : "Post";

    if (commentInput.content.mentions.isEmpty) {
      return {
        "input": [
          {
            "commentBy": {
              "connect": {
                "where": {
                  "node": {
                    "username_EQ": commentInput.username,
                  }
                }
              }
            },
            "commentOn": {
              commentOnNode: {
                "connect": {
                  "where": {
                    "node": {
                      "id_EQ": commentInput.targetNodeId,
                    }
                  }
                }
              }
            },
            "content": commentInput.content.content,
            "media": commentInput.bucketPath ?? "",
          }
        ],
        "where": {
          "username_EQ": commentInput.username,
        }
      };
    }

    return {
      "input": [
        {
          "commentBy": {
            "connect": {
              "where": {
                "node": {
                  "username_EQ": commentInput.username,
                }
              }
            }
          },
          "commentOn": {
            commentOnNode: {
              "connect": {
                "where": {
                  "node": {
                    "id_EQ": commentInput.targetNodeId,
                  }
                }
              }
            }
          },
          "content": commentInput.content.content,
          "media": commentInput.bucketPath ?? "",
          "mentions": {
            "connect": [
              {
                "where": {
                  "node": {
                    "OR": commentInput.generateMentions(),
                  }
                }
              }
            ]
          }
        }
      ],
      "where": {
        "username_EQ": commentInput.username,
      }
    };
  }

  // get comments
  static String getComments(
    bool post, {
    String? cursor,
  }) {
    if (cursor == null || cursor.isEmpty) {
      return '''
        query CommentsConnection(\$first: Int, \$where: CommentWhere, \$likedByWhere2: UserWhere, \$sort: [CommentSort!]) {
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
                commentBy {
                  id
                  username
                  profilePicture
                  name
                }
              }
            }
          }
        }
    ''';
    }

    return '''
      query CommentsConnection(\$first: Int, \$where: CommentWhere, \$likedByWhere2: UserWhere, \$sort: [CommentSort!], \$after: String) {
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
              commentBy {
                id
                username
                profilePicture
                name
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
    required bool post,
    required String username,
  }) {
    String connectionNode = post ? "Post" : "Comment";
    String sort = post ? "DESC" : "ASC";

    if (cursor == null || cursor.isEmpty) {
      return {
        "first": GraphqlQueryConstants.commentLimit,
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
      };
    }

    return {
      "first": GraphqlQueryConstants.commentLimit,
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
    };
  }

  // user like comment
  static String userAddLikeComment() {
    return """
      mutation UpdateComments(\$where: CommentWhere, \$update: CommentUpdateInput, \$likedByWhere2: UserWhere) {
        updateComments(where: \$where, update: \$update) {
          comments {
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
      }
    """;
  }

  static Map<String, dynamic> userAddCommentLikeVariables(
    String commentId, {
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": commentId,
      },
      "update": {
        "likedBy": [
          {
            "connect": [
              {
                "where": {
                  "node": {
                    "username_EQ": username,
                  }
                }
              }
            ]
          }
        ]
      },
      "likedByWhere2": {
        "username_EQ": username,
      }
    };
  }

  static String userRemoveCommentLike() {
    return """
      mutation UpdateComments(\$where: CommentWhere, \$update: CommentUpdateInput, \$likedByWhere2: UserWhere) {
        updateComments(where: \$where, update: \$update) {
          comments {
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
    """;
  }

  static Map<String, dynamic> userRemoveCommentLikeVariables(
    String commentId, {
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": commentId,
      },
      "update": {
        "likedBy": [
          {
            "disconnect": [
              {
                "where": {
                  "node": {
                    "username_EQ": username,
                  }
                }
              }
            ]
          }
        ]
      },
      "likedByWhere2": {
        "username_EQ": username,
      }
    };
  }
}
