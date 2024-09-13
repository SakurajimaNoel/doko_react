import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';

import '../../../../core/helpers/display.dart';

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
        query Query(\$where: UserWhere, \$first: Int, \$sort: [UserPostsConnectionSort!], \$friendsConnectionFirst2: Int, \$friendsConnectionSort2: [UserFriendsConnectionSort!], \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
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
                }
              }
              pageInfo {
                endCursor
                hasNextPage
              }
            }
            friendsConnection(first: \$friendsConnectionFirst2, sort: \$friendsConnectionSort2, where: \$friendsConnectionWhere2) {
              edges {
                node {
                  id
                  name
                  username
                  profilePicture
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

  static Map<String, dynamic> getCompleteUserVariables(String id) {
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
      "friendsConnectionFirst2": QueryConstants.friendLimit,
      "friendsConnectionSort2": const [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
      "friendsConnectionWhere2": const {
        "edge": {
          "status": "ACCEPTED",
        }
      }
    };
  }

  // get user accepted friends by user id
  static String getFriendsByUserId() {
    return """
        query Query(\$where: UserWhere, \$after: String, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
          users(where: \$where) {
            friendsConnection(after: \$after, first: \$first, sort: \$sort, where: \$friendsConnectionWhere2) {
              edges {
                node {
                  id
                  name
                  username
                  profilePicture
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
      String id, String cursor) {
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
      }
    };
  }

  // get user posts by user id
  static String getUserPostsByUserId() {
    return """
        query Users(\$where: UserWhere, \$after: String, \$sort: [UserPostsConnectionSort!], \$first: Int) {
          users(where: \$where) {
            postsConnection(after: \$after, sort: \$sort, first: \$first) {
              edges {
                node {
                  content
                  caption
                  id
                  createdOn
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
      String id, String cursor) {
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
      ]
    };
  }

// get user pending friends outgoing
  static String getPendingOutgoingFriendsByUserId(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
    query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!]) {
      users(where: \$where) {
        friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort) {
          edges {
            node {
              id
              username
              name
              profilePicture
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
    query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$after: String) {
  users(where: \$where) {
    friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort, after: \$after) {
      edges {
        node {
          id
          username
          name
          profilePicture
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
    };
  }

  // get user pending friends incoming
  static String getPendingIncomingFriendsByUserId(String? cursor) {
    if (cursor == null || cursor.isEmpty) {
      return """
      query Query(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!]) {
        users(where: \$where) {
          friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort) {
            edges {
              node {
                id
                name
                username
                profilePicture
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
    query Query(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [UserFriendsConnectionSort!], \$after: String) {
      users(where: \$where) {
        friendsConnection(where: \$friendsConnectionWhere2, first: \$first, sort: \$sort, after: \$after) {
          edges {
            node {
              id
              name
              username
              profilePicture
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
}
