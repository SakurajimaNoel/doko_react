import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';

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

class UserQueries {
  // get user query and variables
  static String getUser() {
    return """
        query Query(\$where: UserWhere) {
          users(where: \$where) {
            id
            name
            username
            profilePicture
          }
        }
        """;
  }

  static Map<String, dynamic> getUserVariables(String id) {
    return {
      "where": {
        "id": id,
      }
    };
  }

  // check username query and variables
  static String checkUsername() {
    return """
          query Query(\$where: UserWhere) {
            users(where: \$where) {
              id
            }
          }
        """;
  }

  static Map<String, dynamic> checkUsernameVariables(String username) {
    return {
      "where": {
        "username": username,
      }
    };
  }

  // complete user profile query and variables
  static String completeUserProfile() {
    return """
        mutation Mutation(\$input: [UserCreateInput!]!) {
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
      CompleteUserProfileVariables userDetails) {
    return {
      "input": [
        {
          "id": userDetails.id,
          "username": userDetails.username,
          "email": userDetails.email,
          "dob": DisplayText.date(userDetails.dob),
          "name": userDetails.name,
          "profilePicture": userDetails.profilePicture,
        }
      ]
    };
  }

  // get complete user
  static String getCompleteUser() {
    return """
      query Query(\$where: UserWhere, \$first: Int, \$sort: [UserPostsConnectionSort!], \$friendsWhere2: UserWhere, \$friendsConnectionWhere4: UserFriendsConnectionWhere, \$likedByWhere2: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
        users(where: \$where) {
          username
          profilePicture
          name
          id
          bio
          dob
          createdOn
          postsConnection(first: \$first, sort: \$sort) {
            edges {
              node {
                content
                id
                createdOn
                caption
                likes
                likedBy(where: \$likedByWhere2) {
                  id
                }
                commentsConnection {
                  totalCount
                }
                likedByConnection {
                  totalCount
                }
              }
            }
            pageInfo {
              endCursor
              hasNextPage
            }
            totalCount
          }
          friendsConnection(where: \$friendsConnectionWhere2) {
            totalCount
          }
          friends(where: \$friendsWhere2) {
            friendsConnection(where: \$friendsConnectionWhere4) {
              edges {
                requestedBy
                status
              }
            }
          }
        }
      }
      """;
  }

  static Map<String, dynamic> getCompleteUserVariables(
    String id, {
    required String currentUserId,
  }) {
    return {
      "where": {
        "id": id,
      },
      "first": QueryConstants.postLimit,
      "sort": const [
        {
          "node": {
            "createdOn": "DESC",
          }
        }
      ],
      "friendsWhere2": {
        "id": currentUserId,
      },
      "friendsConnectionWhere4": {
        "node": {
          "id": id,
        }
      },
      "likedByWhere2": {
        "id": currentUserId,
      },
      "friendsConnectionWhere2": {
        "edge": {
          "status": FriendStatus.accepted,
        }
      },
    };
  }

  // get user accepted friends by user id
  static String getFriendsByUserId(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
       query Query(\$where: UserWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
        users(where: \$where) {
          friendsConnection(first: \$first, sort: \$sort, where: \$friendsConnectionWhere2) {
            edges {
              node {
                id
                name
                username
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    requestedBy
                    status
                  }
                }
              }
            }
            pageInfo {
              endCursor
              hasNextPage
            }
          }
        }
      }
      """;
    }

    return """
        query Query(\$where: UserWhere, \$after: String, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
          users(where: \$where) {
            friendsConnection(after: \$after, first: \$first, sort: \$sort, where: \$friendsConnectionWhere2) {
              edges {
                node {
                  id
                  name
                  username
                  profilePicture
                  friendsConnection(where: \$friendsConnectionWhere3) {
                    edges {
                      requestedBy
                      status
                    }
                  }
                }
              }
              pageInfo {
                endCursor
                hasNextPage
              }
            }
          }
        }
        """;
  }

  static Map<String, dynamic> getFriendsByUserIdVariables(
      String id, String? cursor,
      {required String currentUserId}) {
    if (cursor == null || cursor.isEmpty) {
      return {
        "where": {
          "id": id,
        },
        "first": QueryConstants.friendLimit,
        "sort": [
          {
            "edge": {
              "addedOn": "DESC",
            }
          },
        ],
        "friendsConnectionWhere2": {
          "edge": {
            "status": FriendStatus.accepted,
          }
        },
        "friendsConnectionWhere3": {
          "node": {
            "id": currentUserId,
          }
        }
      };
    }

    return {
      "where": {
        "id": id,
      },
      "after": cursor,
      "first": QueryConstants.friendLimit,
      "sort": const [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
      "friendsConnectionWhere2": const {
        "edge": {
          "status": FriendStatus.accepted,
        }
      },
      "friendsConnectionWhere3": {
        "node": {
          "id": currentUserId,
        }
      }
    };
  }

  // get user posts by user id
  static String getUserPostsByUserId() {
    return """
        query Users(\$where: UserWhere, \$after: String, \$sort: [UserPostsConnectionSort!], \$first: Int, \$likedByWhere2: UserWhere) {
          users(where: \$where) {
            postsConnection(after: \$after, sort: \$sort, first: \$first) {
              edges {
                node {
                  content
                  caption
                  id
                  createdOn
                  likedBy(where: \$likedByWhere2) {
                    id
                  }
                  commentsConnection {
                    totalCount
                  }
                  likedByConnection {
                    totalCount
                  }
                }
              }
              pageInfo {
                endCursor
                hasNextPage
              }
            }
          }
        }
        """;
  }

  static Map<String, dynamic> getUserPostsByUserIdVariables(
      String id, String cursor, String userId) {
    return {
      "where": {
        "id": id,
      },
      "after": cursor,
      "first": QueryConstants.postLimit,
      "sort": const [
        {
          "node": {
            "createdOn": "DESC",
          }
        }
      ],
      "likedByWhere2": {
        "id": userId,
      },
    };
  }

// get user pending friends outgoing
  static String getPendingOutgoingFriendsByUserId(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
    query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
      users(where: \$where) {
        friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort) {
          edges {
            node {
              id
              username
              name
              profilePicture
              friendsConnection(where: \$friendsConnectionWhere3) {
                edges {
                  requestedBy
                  status
                }
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    }
    """;
    }

    return """
    query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$after: String, \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
      users(where: \$where) {
        friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort, after: \$after) {
          edges {
            node {
              id
              username
              name
              profilePicture
              friendsConnection(where: \$friendsConnectionWhere3) {
                edges {
                  requestedBy
                  status
                }
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getPendingOutgoingFriendsByUserIdVariables(
      String id, String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return {
        "where": {
          "id": id,
        },
        "friendsConnectionWhere2": {
          "edge": {
            "status": FriendStatus.pending,
            "requestedBy": id,
          }
        },
        "first": QueryConstants.friendLimit,
        "sort": [
          {
            "edge": {
              "addedOn": "DESC",
            }
          }
        ],
        "friendsConnectionWhere3": {
          "node": {
            "id": id,
          }
        },
      };
    }

    return {
      "where": {
        "id": id,
      },
      "friendsConnectionWhere2": {
        "edge": {
          "status": FriendStatus.pending,
          "requestedBy": id,
        }
      },
      "first": QueryConstants.friendLimit,
      "after": cursor,
      "sort": [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
      "friendsConnectionWhere3": {
        "node": {
          "id": id,
        }
      },
    };
  }

  // get user pending friends incoming
  static String getPendingIncomingFriendsByUserId(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
      query Query(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
        users(where: \$where) {
          friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort) {
            edges {
              node {
                id
                name
                username
                profilePicture
                friendsConnection(where: \$friendsConnectionWhere3) {
                  edges {
                    requestedBy
                    status
                  }
                }
              }
            }
            pageInfo {
              endCursor
              hasNextPage
            }
          }
        }
      }     
    """;
    }

    return """
    query Query(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere3: UserFriendsConnectionWhere, \$after: String) {
      users(where: \$where) {
        friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort, after: \$after) {
          edges {
            node {
              id
              name
              username
              profilePicture
              friendsConnection(where: \$friendsConnectionWhere3) {
                edges {
                  requestedBy
                  status
                }
              }
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    }
     """;
  }

  static Map<String, dynamic> getPendingIncomingFriendsByUserIdVariables(
      String id, String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return {
        "where": {
          "id": id,
        },
        "friendsConnectionWhere2": {
          "edge": {
            "status": FriendStatus.pending,
            "NOT": {
              "requestedBy": id,
            }
          }
        },
        "first": QueryConstants.friendLimit,
        "sort": [
          {
            "edge": {
              "addedOn": "DESC",
            }
          }
        ]
      };
    }

    return {
      "where": {
        "id": id,
      },
      "friendsConnectionWhere2": {
        "edge": {
          "status": FriendStatus.pending,
          "NOT": {
            "requestedBy": id,
          }
        }
      },
      "first": QueryConstants.friendLimit,
      "after": cursor,
      "sort": [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
      "friendsConnectionWhere3": {
        "node": {
          "id": id,
        }
      }
    };
  }

  // update user profile
  static String updateUserProfile() {
    return """
    mutation Mutation(\$where: UserWhere, \$update: UserUpdateInput) {
      updateUsers(where: \$where, update: \$update) {
        users {
          name
          profilePicture
          username
          id
        }
      }
    }
    """;
  }

  static Map<String, dynamic> updateUserProfileVariables(
      String id, String name, String bio, String profilePicture) {
    return {
      "where": {
        "id": id,
      },
      "update": {
        "name": name,
        "bio": bio,
        "profilePicture": profilePicture,
      }
    };
  }

  // user send friend request
  // TODO: search for method to merge to avoid duplicate relationship
  static String userSendFriendRequest() {
    return """
    mutation Mutation(\$where: UserWhere, \$connect: UserConnectInput) {
      updateUsers(where: \$where, connect: \$connect) {
        info {
          relationshipsCreated
        }
      }
    }    
    """;
  }

  static Map<String, dynamic> userSendFriendRequestVariables(
      String requestedBy, String requestedTo) {
    return {
      "where": {
        "id": requestedBy,
      },
      "connect": {
        "friends": [
          {
            "where": {
              "node": {
                "id": requestedTo,
              },
            },
            "edge": {
              "requestedBy": requestedBy,
              "status": "PENDING",
            }
          }
        ]
      }
    };
  }

  // user accept friend request
  static String userAcceptFriendRequest() {
    return """
      mutation Mutation(\$where: UserWhere, \$update: UserUpdateInput) {
        updateUsers(where: \$where, update: \$update) {
          info {
            relationshipsCreated
          }
        }
      }      
    """;
  }

  static Map<String, dynamic> userAcceptFriendRequestVariables(
      String requestedBy, String requestedTo) {
    return {
      "where": {
        "id": requestedBy,
      },
      "update": {
        "friends": [
          {
            "where": {
              "node": {
                "id": requestedTo,
              },
            },
            "update": {
              "edge": {
                "status": "ACCEPTED",
              },
            }
          }
        ]
      }
    };
  }

  // user remove friend relation
  static String userRemoveFriendRelation() {
    return """
    mutation Mutation(\$where: UserWhere, \$disconnect: UserDisconnectInput) {
      updateUsers(where: \$where, disconnect: \$disconnect) {
        info {
          relationshipsDeleted
        }
      }
    }
  """;
  }

  static Map<String, dynamic> userRemoveFriendRelationVariables(
      String requestedBy, String requestedTo) {
    return {
      "where": {
        "id": requestedBy,
      },
      "disconnect": {
        "friends": [
          {
            "where": {
              "node": {
                "id": requestedTo,
              }
            }
          }
        ]
      }
    };
  }

  // use create post
  static String userCreatePost() {
    return """
    mutation Mutation(\$input: [PostCreateInput!]!) {
      createPosts(input: \$input) {
        info {
          nodesCreated
          relationshipsCreated
        }
      }
    }        
    """;
  }

  static Map<String, dynamic> userCreatePostVariables({
    required String userId,
    required String caption,
    required List<String> content,
  }) {
    return {
      "input": [
        {
          "caption": caption,
          "content": content,
          "createdBy": {
            "connect": {
              "where": {
                "node": {
                  "id": userId,
                }
              }
            }
          },
          "likes": 0,
        }
      ],
    };
  }

  // post action like
  static String userAddLikePost() {
    return """
    mutation Mutation(\$where: PostWhere, \$connect: PostConnectInput) {
      updatePosts(where: \$where, connect: \$connect) {
        info {
          relationshipsCreated
        }
      }
    }
    """;
  }

  static Map<String, dynamic> userAddLikePostVariables({
    required String postId,
    required String userId,
  }) {
    return {
      "where": {
        "id": postId,
      },
      "connect": {
        "likedBy": [
          {
            "where": {
              "node": {
                "id": userId,
              }
            }
          }
        ]
      },
    };
  }

  static String userRemoveLikePost() {
    return """
    mutation Mutation(\$where: PostWhere, \$disconnect: PostDisconnectInput) {
      updatePosts(where: \$where, disconnect: \$disconnect) {
        info {
          relationshipsDeleted
        }
      }
    }
    """;
  }

  static Map<String, dynamic> userRemoveLikePostVariables({
    required String postId,
    required String userId,
  }) {
    return {
      "where": {
        "id": postId,
      },
      "disconnect": {
        "likedBy": [
          {
            "where": {
              "node": {
                "id": userId,
              }
            }
          }
        ]
      },
    };
  }

  // search user based on username or name
  static String searchUserByUsernameOrName() {
    return '''
    query Users(\$options: UserOptions, \$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
      users(options: \$options, where: \$where) {
        id
        name
        username
        profilePicture
        friendsConnection(where: \$friendsConnectionWhere2) {
          edges {
            requestedBy
            status
          }
        }
      }
    }
    ''';
  }

  static Map<String, dynamic> searchUserByUsernameOrNameVariables(
      String id, String query) {
    return {
      "options": {
        "limit": QueryConstants.generalSearchLimit,
      },
      "where": {
        "AND": [
          {
            "OR": [
              {
                "name_CONTAINS": query,
              },
              {
                "username_CONTAINS": query,
              }
            ],
          },
          {
            "NOT": {
              "id": id,
            }
          }
        ],
      },
      "friendsConnectionWhere2": {
        "node": {
          "id": id,
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
              name
              profilePicture
              username
              friendsConnection(where: \$friendsConnectionWhere3) {
                edges {
                  requestedBy
                  status
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
      String userId, String myId, String query) {
    return {
      "where": {
        "id": userId,
      },
      "first": QueryConstants.friendSearchLimit,
      "friendsConnectionWhere2": {
        "edge": {
          "status": FriendStatus.accepted,
        },
        "node": {
          "OR": [
            {
              "name_CONTAINS": query,
            },
            {
              "username_CONTAINS": query,
            },
          ],
        }
      },
      "friendsConnectionWhere3": {
        "node": {
          "id": myId,
        }
      },
    };
  }

  // search user friends by username
  static String searchUserFriendsByUsername() {
    return '''
    query Users(\$where: UserWhere, \$first: Int, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
      users(where: \$where) {
        friendsConnection(first: \$first, where: \$friendsConnectionWhere2) {
          edges {
            node {
              id
              name
              profilePicture
              username
            }
          }
        }
      }
    }
    ''';
  }

  static Map<String, dynamic> searchUserFriendsByUsernameVariables(
      String id, String query) {
    return {
      "where": {
        "id": id,
      },
      "first": QueryConstants.friendSearchCommentLimit,
      "friendsConnectionWhere2": {
        "node": {
          "username_CONTAINS": query,
        },
        "edge": {
          "status": FriendStatus.accepted,
        }
      }
    };
  }
}
