import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/features/User/data/graphql_queries/query_constants.dart';
import 'package:doko_react/features/User/data/model/comment_model.dart';

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
      query Users(\$where: UserWhere, \$friendsWhere2: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$likedByWhere2: UserWhere, \$sort: [UserPostsConnectionSort!], \$friendsConnectionWhere3: UserFriendsConnectionWhere) {
        users(where: \$where) {
          id
          username
          createdOn
          name
          profilePicture
          bio
          dob
          friends(where: \$friendsWhere2) {
            friendsConnection(where: \$friendsConnectionWhere3) {
              edges {
                properties {
                  status
                  requestedBy
                  addedOn
                }
              }
            }
          }
          friendsConnection(where: \$friendsConnectionWhere2) {
            totalCount
          }
          postsConnection(first: \$first, sort: \$sort) {
            totalCount
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
      }
    """;
  }

  static Map<String, dynamic> getCompleteUserVariables(
    String username, {
    required String currentUsername,
  }) {
    return {
      "where": {
        "username_EQ": username,
      },
      "friendsWhere2": {
        "username_EQ": currentUsername,
      },
      "friendsConnectionWhere2": {
        "edge": {
          "status_EQ": FriendStatus.accepted,
        }
      },
      "first": QueryConstants.postLimit,
      "likedByWhere2": {
        "username_EQ": currentUsername,
      },
      "sort": [
        {
          "node": {
            "createdOn": "DESC",
          }
        }
      ],
      "friendsConnectionWhere3": {
        "node": {
          "username_EQ": username,
        }
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
        "first": QueryConstants.friendLimit,
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
      "first": QueryConstants.friendLimit,
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
      "first": QueryConstants.postLimit,
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
        "first": QueryConstants.friendLimit,
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
      "first": QueryConstants.friendLimit,
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
        "first": QueryConstants.friendLimit,
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
      "first": QueryConstants.friendLimit,
      "sort": [
        {
          "edge": {
            "addedOn": "DESC",
          }
        }
      ],
    };
    ;
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
    mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput) {
      updateUsers(where: \$where, update: \$update) {
        info {
          relationshipsCreated
        }
      }
    }    
    """;
  }

  static Map<String, dynamic> userSendFriendRequestVariables({
    required String requestedByUsername,
    required String requestedToUsername,
  }) {
    return {
      "where": {
        "username_EQ": requestedByUsername,
      },
      "update": {
        "friends": [
          {
            "connect": [
              {
                "edge": {
                  "requestedBy": requestedByUsername,
                  "status": FriendStatus.pending,
                },
                "where": {
                  "node": {
                    "username_EQ": requestedToUsername,
                  }
                }
              }
            ]
          }
        ]
      }
    };
  }

  // user accept friend request
  static String userAcceptFriendRequest() {
    return """
      mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput) {
        updateUsers(where: \$where, update: \$update) {
          info {
            relationshipsCreated
          }
        }
      }     
    """;
  }

  static Map<String, dynamic> userAcceptFriendRequestVariables({
    required String requestedByUsername,
    required String requestedToUsername,
  }) {
    return {
      "where": {
        "username_EQ": requestedByUsername,
      },
      "update": {
        "friends": [
          {
            "where": {
              "node": {
                "username_EQ": requestedToUsername,
              }
            },
            "update": {
              "edge": {
                "status": FriendStatus.accepted,
              }
            }
          }
        ]
      }
    };
  }

  // user remove friend relation
  static String userRemoveFriendRelation() {
    return """
    mutation UpdateUsers(\$where: UserWhere, \$update: UserUpdateInput) {
      updateUsers(where: \$where, update: \$update) {
        info {
          relationshipsDeleted
        }
      }
    }
  """;
  }

  static Map<String, dynamic> userRemoveFriendRelationVariables({
    required String requestedByUsername,
    required String requestedToUsername,
  }) {
    return {
      "where": {
        "username_EQ": requestedByUsername,
      },
      "update": {
        "friends": [
          {
            "disconnect": [
              {
                "where": {
                  "node": {
                    "username_EQ": requestedToUsername,
                  }
                }
              }
            ]
          }
        ]
      }
    };
  }

  // use create post
  static String userCreatePost() {
    return """
      mutation CreatePosts(\$input: [PostCreateInput!]!) {
        createPosts(input: \$input) {
          info {
            nodesCreated
            relationshipsCreated
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
          "createdBy": {
            "connect": {
              "where": {
                "node": {
                  "username_EQ": username,
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
  // TODO update user like and comment count from here
  static String userAddLikePost() {
    return """
      mutation UpdatePosts(\$where: PostWhere, \$update: PostUpdateInput) {
        updatePosts(where: \$where, update: \$update) {
          info {
            relationshipsCreated
          }
          posts {
            likedByConnection {
              totalCount
            }
            commentsConnection {
              totalCount
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
      }
    };
  }

  static String userRemoveLikePost() {
    return """
      mutation UpdatePosts(\$where: PostWhere, \$update: PostUpdateInput) {
        updatePosts(where: \$where, update: \$update) {
          info {
            relationshipsDeleted
          }
          posts {
            likedByConnection {
              totalCount
            }
            commentsConnection {
              totalCount
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
      }
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
    String query, {
    required String username,
  }) {
    return {
      "options": {
        "limit": QueryConstants.generalSearchLimit,
      },
      "where": {
        "OR": [
          {
            "name_CONTAINS": query,
          },
          {
            "username_CONTAINS": query,
          }
        ],
      },
      "friendsConnectionWhere2": {
        "node": {
          "username": username,
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
    String username, {
    required String currentUsername,
    required String query,
  }) {
    return {
      "where": {
        "username": username,
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
          "username": currentUsername,
        }
      },
    };
  }

  // search user friends by username for comment mention
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
    String username, {
    required String query,
  }) {
    return {
      "where": {
        "username": username,
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

  // post by id
  static String getPostById() {
    return """
      query Posts(\$where: PostWhere, \$likedByWhere2: UserWhere, \$first: Int, \$sort: [PostCommentsConnectionSort!], \$likedByWhere3: UserWhere) {
        posts(where: \$where) {
          caption
          id
          content
          createdOn
          createdBy {
            id
            name
            profilePicture
            username
          }
          likedBy(where: \$likedByWhere2) {
            id
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
                commentsConnection {
                  totalCount
                }
                commentBy {
                  id
                  username
                  name
                  profilePicture
                }
                likedBy(where: \$likedByWhere3) {
                  username
                }
              }
            }
          }
          likedByConnection {
            totalCount
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
        "id": postId,
      },
      "likedByWhere2": {
        "username": username,
      },
      "first": QueryConstants.commentLimit,
      "sort": [
        {
          "node": {"createdOn": "ASC"}
        }
      ],
      "likedByWhere3": {"username": username}
    };
  }

  // add comment
  static String addComment() {
    return '''
    mutation CreateComments(\$input: [CommentCreateInput!]!, \$where: UserWhere) {
      createComments(input: \$input) {
        comments {
          id
          media
          mentions {
            username
          }
          content
          createdOn
          commentBy {
            id
            name
            username
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
      CommentInputModel commentInput) {
    String commentOnNode = commentInput.isReply ? "Comment" : "Post";

    if (commentInput.mentions.isEmpty) {
      return {
        "input": [
          {
            "media": commentInput.media,
            "content": commentInput.content,
            "commentBy": {
              "connect": {
                "where": {
                  "node": {
                    "username": commentInput.commentBy,
                  },
                },
              }
            },
            "commentOn": {
              commentOnNode: {
                "connect": {
                  "where": {
                    "node": {
                      "id": commentInput.commentOn,
                    }
                  }
                }
              }
            }
          }
        ],
        "where": {
          "username": commentInput.commentBy,
        }
      };
    }

    return {
      "input": [
        {
          "media": commentInput.media,
          "content": commentInput.content,
          "commentBy": {
            "connect": {
              "where": {
                "node": {
                  "username": commentInput.commentBy,
                },
              },
            }
          },
          "commentOn": {
            commentOnNode: {
              "connect": {
                "where": {
                  "node": {
                    "id": commentInput.commentOn,
                  }
                }
              }
            }
          },
          "mentions": {
            "connect": [
              {
                "where": {
                  "node": {
                    "OR": commentInput.generateMentions(),
                  }
                }
              }
            ],
          }
        }
      ],
      "where": {
        "username": commentInput.commentBy,
      }
    };
  }

  // get comments
  static String getComments() {
    return '''
    query CommentsConnection(\$where: CommentWhere, \$first: Int, \$sort: [CommentSort], \$after: String, \$likedByWhere2: UserWhere) {
      commentsConnection(where: \$where, first: \$first, sort: \$sort, after: \$after) {
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
            commentsConnection {
              totalCount
            }
            commentBy {
              id
              username
              name
              profilePicture
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

  static Map<String, dynamic> getCommentsVariable(
    bool post, {
    String? cursor,
    required String nodeId,
    required String username,
  }) {
    String connectionNode = post ? "Post" : "Comment";

    if (cursor == null) {
      return {
        "where": {
          "commentOnConnection": {
            connectionNode: {
              "node": {
                "id": nodeId,
              }
            }
          }
        },
        "first": QueryConstants.commentLimit,
        "sort": [
          {
            "createdOn": "ASC",
          }
        ],
        "likedByWhere2": {
          "username": username,
        }
      };
    }

    return {
      "where": {
        "commentOnConnection": {
          connectionNode: {
            "node": {
              "id": nodeId,
            }
          }
        }
      },
      "first": QueryConstants.commentLimit,
      "after": cursor,
      "sort": [
        {
          "createdOn": "ASC",
        }
      ],
      "likedByWhere2": {
        "username": username,
      }
    };
  }
}
