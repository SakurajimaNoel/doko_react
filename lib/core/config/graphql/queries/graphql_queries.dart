import 'package:doko_react/core/config/graphql/graphql_constants.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/query/query_helper.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';

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
      query Users(\$where: UserWhere, \$friendsConnectionWhere3: UserFriendsConnectionWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$sort: [ContentSort!], \$contentsConnectionWhere2: ContentWhere, \$likedByWhere2: UserWhere, \$votesConnectionWhere2: PollVotesConnectionWhere, \$votesConnectionWhere3: PollVotesConnectionWhere, \$votesConnectionWhere4: PollVotesConnectionWhere, \$votesConnectionWhere5: PollVotesConnectionWhere, \$votesConnectionWhere6: PollVotesConnectionWhere, \$votesConnectionWhere7: PollVotesConnectionWhere) {
        users(where: \$where) {
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
          discussionsAggregate {
            count
          }
          pollsAggregate {
            count
          }
          friendsAggregate:friendsConnection(where: \$friendsConnectionWhere3) {
            count:totalCount
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
        contentsConnection(first: \$first, sort: \$sort, where: \$contentsConnectionWhere2) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              __typename
              id
              createdOn
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
              usersTagged {
                username
                profilePicture
              }
              likedByConnection {
                totalCount
              }
              commentsConnection {
                totalCount
              }
              ... on Post {
                content
                caption
              }
              ... on Discussion {
                title
                text
                media
              }
              ... on Poll {
                question
                options
                activeTill
             
                selfVote: votesConnection(where: \$votesConnectionWhere2) {
                  edges {
                    properties {
                      addedOn
                      option
                    }
                  }
                }
                optionA: votesConnection (where: \$votesConnectionWhere3){
                  totalCount
                }
                optionB: votesConnection (where: \$votesConnectionWhere4){
                  totalCount
                }
                optionC: votesConnection (where: \$votesConnectionWhere5){
                  totalCount
                }
                optionD: votesConnection (where: \$votesConnectionWhere6){
                  totalCount
                }
                optionE: votesConnection (where: \$votesConnectionWhere7){
                  totalCount
                }
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
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
      "friendsConnectionWhere3": {
        "edge": {
          "status_EQ": FriendStatus.accepted,
        }
      },
      "first": GraphqlConstants.nodeLimit,
      "sort": [
        {"createdOn": "DESC"}
      ],
      "contentsConnectionWhere2": {
        "OR": [
          {
            "createdBy": {
              "username_EQ": username,
            },
          },
          {
            "usersTagged_SOME": {
              "username_EQ": username,
            },
          }
        ]
      },
      "likedByWhere2": {
        "username_EQ": currentUsername,
      },
      "votesConnectionWhere2": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
      "votesConnectionWhere3": {
        "edge": {
          "option_EQ": PollOption.optionA.value,
        }
      },
      "votesConnectionWhere4": {
        "edge": {
          "option_EQ": PollOption.optionB.value,
        }
      },
      "votesConnectionWhere5": {
        "edge": {
          "option_EQ": PollOption.optionC.value,
        }
      },
      "votesConnectionWhere6": {
        "edge": {
          "option_EQ": PollOption.optionD.value,
        }
      },
      "votesConnectionWhere7": {
        "edge": {
          "option_EQ": PollOption.optionE.value,
        }
      },
    };
  }

  // get more timeline nodes
  static String getUserTimelineNodes() {
    return """
    query ContentsConnection(\$first: Int, \$after: String, \$sort: [ContentSort!], \$where: ContentWhere, \$likedByWhere2: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$votesConnectionWhere2: PollVotesConnectionWhere, \$votesConnectionWhere3: PollVotesConnectionWhere, \$votesConnectionWhere4: PollVotesConnectionWhere, \$votesConnectionWhere5: PollVotesConnectionWhere, \$votesConnectionWhere6: PollVotesConnectionWhere, \$votesConnectionWhere7: PollVotesConnectionWhere) {
      contentsConnection(first: \$first, after: \$after, sort: \$sort, where: \$where) {
        pageInfo {
          endCursor
          hasNextPage
        }
        edges {
          node {
            __typename
            id
            createdOn
            commentsConnection {
              totalCount
            }
            likedByConnection {
              totalCount
            }
            usersTagged {
              username
              profilePicture
            }
            likedBy(where: \$likedByWhere2) {
              username
            }
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
            ... on Discussion {
              media
              text
              title
            }
            ... on Poll {
              question
              options
              activeTill
             
              selfVote: votesConnection(where: \$votesConnectionWhere2) {
                edges {
                  properties {
                    addedOn
                    option
                  }
                }
              }
              optionA: votesConnection (where: \$votesConnectionWhere3){
                totalCount
              }
              optionB: votesConnection (where: \$votesConnectionWhere4){
                totalCount
              }
              optionC: votesConnection (where: \$votesConnectionWhere5){
                totalCount
              }
              optionD: votesConnection (where: \$votesConnectionWhere6){
                totalCount
              }
              optionE: votesConnection (where: \$votesConnectionWhere7){
                totalCount
              }
            }
            ... on Post {
              caption
              content
            }
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getUserTimelineNodesVariables({
    required String cursor,
    required String username,
    required String currentUsername,
  }) {
    return {
      "first": GraphqlConstants.nodeLimit,
      "after": cursor,
      "sort": [
        {
          "createdOn": "DESC",
        }
      ],
      "where": {
        "OR": [
          {
            "createdBy": {
              "username_EQ": username,
            },
          },
          {
            "usersTagged_SOME": {
              "username_EQ": username,
            },
          }
        ]
      },
      "likedByWhere2": {
        "username_EQ": currentUsername,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
      "votesConnectionWhere2": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
      "votesConnectionWhere3": {
        "edge": {
          "option_EQ": PollOption.optionA.value,
        }
      },
      "votesConnectionWhere4": {
        "edge": {
          "option_EQ": PollOption.optionB.value,
        }
      },
      "votesConnectionWhere5": {
        "edge": {
          "option_EQ": PollOption.optionC.value,
        }
      },
      "votesConnectionWhere6": {
        "edge": {
          "option_EQ": PollOption.optionD.value,
        }
      },
      "votesConnectionWhere7": {
        "edge": {
          "option_EQ": PollOption.optionE.value,
        }
      },
    };
  }

  // get user accepted friends by username
  static String getFriendsByUsername() {
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
    required String cursor,
    required String currentUsername,
  }) {
    return {
      "where": {
        "username_EQ": username,
      },
      "after": cursor,
      "first": GraphqlConstants.nodeLimit,
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
        query Query(\$first: Int, \$sort: [PostSort!], \$where: PostWhere, \$likedByWhere2: UserWhere, \$after: String) {
          postsConnection(first: \$first, sort: \$sort, where: \$where, after: \$after) {
            pageInfo {
              hasNextPage
              endCursor
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
                usersTagged {
                  username
                  profilePicture
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
      "first": GraphqlConstants.nodeLimit,
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

  // get user discussion
  static String getUserDiscussionsByUsername() {
    return """
    query DiscussionsConnection(\$sort: [DiscussionSort!], \$where: DiscussionWhere, \$likedByWhere2: UserWhere, \$first: Int, \$after: String) {
      discussionsConnection(sort: \$sort, where: \$where, first: \$first, after: \$after) {
        pageInfo {
          endCursor
          hasNextPage
        }
        edges {
          node {
            id
            createdOn
            title
            text
            media
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
            usersTagged {
              username
              profilePicture
            }
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getUserDiscussionsByUsernameVariables({
    required String username,
    required String cursor,
    required String currentUsername,
  }) {
    return {
      "sort": [
        {"createdOn": "DESC"}
      ],
      "where": {
        "createdBy": {
          "username_EQ": username,
        }
      },
      "likedByWhere2": {
        "username_EQ": currentUsername,
      },
      "first": GraphqlConstants.nodeLimit,
      "after": cursor,
    };
  }

  static String getUserPollsByUsername() {
    return """
    query PollsConnection(\$first: Int, \$sort: [PollSort!], \$where: PollWhere, \$likedByWhere2: UserWhere, \$votesConnectionWhere2: PollVotesConnectionWhere, \$after: String, \$votesConnectionWhere3: PollVotesConnectionWhere, \$votesConnectionWhere4: PollVotesConnectionWhere, \$votesConnectionWhere5: PollVotesConnectionWhere, \$votesConnectionWhere6: PollVotesConnectionWhere, \$votesConnectionWhere7: PollVotesConnectionWhere) {
      pollsConnection(first: \$first, sort: \$sort, where: \$where, after: \$after) {
        pageInfo {
          endCursor
          hasNextPage
        }
        edges {
          node {
            id
            createdOn
            question
            options
            activeTill
            usersTagged {
              username
              profilePicture
            }
            likedBy(where: \$likedByWhere2) {
              username
            }
            commentsConnection {
              totalCount
            }
            likedByConnection {
              totalCount
            }
            createdBy {
              username
            }
            
            selfVote: votesConnection(where: \$votesConnectionWhere2) {
              edges {
                properties {
                  addedOn
                  option
                }
              }
            }
            optionA: votesConnection (where: \$votesConnectionWhere3){
              totalCount
            }
            optionB: votesConnection (where: \$votesConnectionWhere4){
              totalCount
            }
            optionC: votesConnection (where: \$votesConnectionWhere5){
              totalCount
            }
            optionD: votesConnection (where: \$votesConnectionWhere6){
              totalCount
            }
            optionE: votesConnection (where: \$votesConnectionWhere7){
              totalCount
            }
          }
        }
      }
    }

    """;
  }

  static Map<String, dynamic> getUserPollsByUsernameVariables({
    required String username,
    required String cursor,
    required String currentUsername,
  }) {
    return {
      "first": GraphqlConstants.nodeLimit,
      "after": cursor,
      "sort": [
        {"createdOn": "DESC"}
      ],
      "where": {
        "createdBy": {
          "username_EQ": username,
        }
      },
      "likedByWhere2": {
        "username_EQ": currentUsername,
      },
      "votesConnectionWhere2": {
        "node": {
          "username_EQ": currentUsername,
        }
      },
      "votesConnectionWhere3": {
        "edge": {
          "option_EQ": PollOption.optionA.value,
        }
      },
      "votesConnectionWhere4": {
        "edge": {
          "option_EQ": PollOption.optionB.value,
        }
      },
      "votesConnectionWhere5": {
        "edge": {
          "option_EQ": PollOption.optionC.value,
        }
      },
      "votesConnectionWhere6": {
        "edge": {
          "option_EQ": PollOption.optionD.value,
        }
      },
      "votesConnectionWhere7": {
        "edge": {
          "option_EQ": PollOption.optionE.value,
        }
      },
    };
  }

// get user pending friends outgoing
  static String getPendingOutgoingFriendsByUsername() {
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
      "first": GraphqlConstants.nodeLimit,
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
  static String getPendingIncomingFriendsByUsername() {
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
      "first": GraphqlConstants.nodeLimit,
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
     query Posts(\$where: PostWhere, \$likedByWhere2: UserWhere, \$first: Int, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
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
        usersTagged {
          username
          profilePicture
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
              likedBy(where: \$likedByWhere2) {
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
      "first": GraphqlConstants.nodeLimit,
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
    };
  }

  // get comments
  static String getComments() {
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

    return {
      "first": GraphqlConstants.nodeLimit,
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
          usersTagged {
            username
            profilePicture
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
      "first": GraphqlConstants.nodeLimit,
      "sort": [
        {
          "node": {
            "createdOn": "ASC",
          }
        }
      ],
    };
  }

  // get discussion by id
  static String getCompleteDiscussionById() {
    return """
    query Discussions(\$where: DiscussionWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$likedByWhere2: UserWhere, \$first: Int) {
      discussions(where: \$where) {
        id
        createdOn
        title
        text
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
        likedByConnection {
          totalCount
        }
        usersTagged {
          username
          profilePicture
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
              likedBy(where: \$likedByWhere2) {
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
        }
        likedBy(where: \$likedByWhere2) {
          username
        }
      }
    }
    """;
  }

  static Map<String, dynamic> getCompleteDiscussionByIdVariables({
    required String discussionId,
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": discussionId,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "first": GraphqlConstants.nodeLimit,
    };
  }

  // discussion in user inbox
  static String getDiscussionById() {
    return """
    query Discussions(\$where: DiscussionWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$likedByWhere2: UserWhere) {
      discussions(where: \$where) {
        id
        createdOn
        title
        text
        media
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
        likedByConnection {
          totalCount
        }
        usersTagged {
          username
          profilePicture
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

  static Map<String, dynamic> getDiscussionByIdVariables({
    required String discussionId,
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": discussionId,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "likedByWhere2": {
        "username_EQ": username,
      }
    };
  }

  /// get poll by id for inbox
  static String getPollById() {
    return """
    query Polls(\$where: PollWhere, \$likedByWhere2: UserWhere, \$votesConnectionWhere2: PollVotesConnectionWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$votesConnectionWhere3: PollVotesConnectionWhere, \$votesConnectionWhere4: PollVotesConnectionWhere, \$votesConnectionWhere5: PollVotesConnectionWhere, \$votesConnectionWhere6: PollVotesConnectionWhere, \$votesConnectionWhere7: PollVotesConnectionWhere) {
      polls(where: \$where) {
        id
        createdOn
        question
        options
        activeTill
        usersTagged {
          username
          profilePicture
        }
        likedBy(where: \$likedByWhere2) {
          username
        }
        commentsConnection {
          totalCount
        }
        likedByConnection {
          totalCount
        }
        
        selfVote: votesConnection(where: \$votesConnectionWhere2) {
          edges {
            properties {
              addedOn
              option
            }
          }
        }
        optionA: votesConnection (where: \$votesConnectionWhere3){
          totalCount
        }
        optionB: votesConnection (where: \$votesConnectionWhere4){
          totalCount
        }
        optionC: votesConnection (where: \$votesConnectionWhere5){
          totalCount
        }
        optionD: votesConnection (where: \$votesConnectionWhere6){
          totalCount
        }
        optionE: votesConnection (where: \$votesConnectionWhere7){
          totalCount
        }
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
      }
    }
    """;
  }

  static Map<String, dynamic> getPollByIdVariables({
    required String pollId,
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": pollId,
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "votesConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "votesConnectionWhere3": {
        "edge": {
          "option_EQ": PollOption.optionA.value,
        }
      },
      "votesConnectionWhere4": {
        "edge": {
          "option_EQ": PollOption.optionB.value,
        }
      },
      "votesConnectionWhere5": {
        "edge": {
          "option_EQ": PollOption.optionC.value,
        }
      },
      "votesConnectionWhere6": {
        "edge": {
          "option_EQ": PollOption.optionD.value,
        }
      },
      "votesConnectionWhere7": {
        "edge": {
          "option_EQ": PollOption.optionE.value,
        }
      },
    };
  }

  static String getCompletePollById() {
    return """
    query Polls(\$where: PollWhere, \$likedByWhere2: UserWhere, \$votesConnectionWhere2: PollVotesConnectionWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere, \$first: Int, \$votesConnectionWhere3: PollVotesConnectionWhere, \$votesConnectionWhere4: PollVotesConnectionWhere, \$votesConnectionWhere5: PollVotesConnectionWhere, \$votesConnectionWhere6: PollVotesConnectionWhere, \$votesConnectionWhere7: PollVotesConnectionWhere) {
      polls(where: \$where) {
        id
        createdOn
        question
        options
        activeTill
        usersTagged {
          username
          profilePicture
        }
        likedBy(where: \$likedByWhere2) {
          username
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
              likedByConnection {
                totalCount
              }
              commentsConnection {
                totalCount
              }
              likedBy(where: \$likedByWhere2) {
                username
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
        likedByConnection {
          totalCount
        }
      
        selfVote: votesConnection(where: \$votesConnectionWhere2) {
          edges {
            properties {
              addedOn
              option
            }
          }
        }
        optionA: votesConnection (where: \$votesConnectionWhere3){
          totalCount
        }
        optionB: votesConnection (where: \$votesConnectionWhere4){
          totalCount
        }
        optionC: votesConnection (where: \$votesConnectionWhere5){
          totalCount
        }
        optionD: votesConnection (where: \$votesConnectionWhere6){
          totalCount
        }
        optionE: votesConnection (where: \$votesConnectionWhere7){
          totalCount
        }
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
      }
    }
    """;
  }

  static Map<String, dynamic> getCompletePollByIdVariables({
    required String pollId,
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": pollId,
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "votesConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "first": GraphqlConstants.nodeLimit,
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "votesConnectionWhere3": {
        "edge": {
          "option_EQ": PollOption.optionA.value,
        }
      },
      "votesConnectionWhere4": {
        "edge": {
          "option_EQ": PollOption.optionB.value,
        }
      },
      "votesConnectionWhere5": {
        "edge": {
          "option_EQ": PollOption.optionC.value,
        }
      },
      "votesConnectionWhere6": {
        "edge": {
          "option_EQ": PollOption.optionD.value,
        }
      },
      "votesConnectionWhere7": {
        "edge": {
          "option_EQ": PollOption.optionE.value,
        }
      },
    };
  }

  // basic user feed
  static String userFeed() {
    return """
    query ContentsConnection(\$first: Int, \$where: UserFriendsConnectionWhere, \$likedByWhere2: UserWhere, \$votesConnectionWhere2: PollVotesConnectionWhere, \$votesConnectionWhere3: PollVotesConnectionWhere, \$votesConnectionWhere4: PollVotesConnectionWhere, \$votesConnectionWhere5: PollVotesConnectionWhere, \$votesConnectionWhere6: PollVotesConnectionWhere, \$votesConnectionWhere7: PollVotesConnectionWhere, \$contentsConnectionWhere2: ContentWhere, \$after: String, \$sort: [ContentSort!]) {
      contentsConnection(first: \$first, where: \$contentsConnectionWhere2, after: \$after, sort: \$sort) {
        pageInfo {
          endCursor
          hasNextPage
        }
        edges {
          node {
            __typename
            id
            createdOn
            createdBy {
              id
              username
              name
              profilePicture
              friendsConnection(where: \$where) {
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
            commentsConnection {
              totalCount
            }
            usersTagged {
              username
              profilePicture
            }
            ... on Post {
              content
              caption
            }
            ... on Discussion {
              title
              text
              media
            }
            ... on Poll {
              question
              options
              activeTill
              selfVote: votesConnection(where: \$votesConnectionWhere2) {
                      edges {
                        properties {
                          addedOn
                          option
                        }
                      }
                    }
                    optionA: votesConnection (where: \$votesConnectionWhere3){
                      totalCount
                    }
                    optionB: votesConnection (where: \$votesConnectionWhere4){
                      totalCount
                    }
                    optionC: votesConnection (where: \$votesConnectionWhere5){
                      totalCount
                    }
                    optionD: votesConnection (where: \$votesConnectionWhere6){
                      totalCount
                    }
                    optionE: votesConnection (where: \$votesConnectionWhere7){
                      totalCount
                    }
            }
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> userFeedVariables({
    required String username,
    required String cursor,
  }) {
    return {
      "first": GraphqlConstants.nodeLimit,
      "after": cursor,
      "sort": [
        {
          "createdOn": "DESC",
        }
      ],
      "where": {
        "node": {
          "username_EQ": username,
        }
      },
      "likedByWhere2": {
        "username_EQ": username,
      },
      "votesConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      },
      "votesConnectionWhere3": {
        "edge": {
          "option_EQ": PollOption.optionA.value,
        }
      },
      "votesConnectionWhere4": {
        "edge": {
          "option_EQ": PollOption.optionB.value,
        }
      },
      "votesConnectionWhere5": {
        "edge": {
          "option_EQ": PollOption.optionC.value,
        }
      },
      "votesConnectionWhere6": {
        "edge": {
          "option_EQ": PollOption.optionD.value,
        }
      },
      "votesConnectionWhere7": {
        "edge": {
          "option_EQ": PollOption.optionE.value,
        }
      },
      "contentsConnectionWhere2": {
        "OR": [
          {
            "createdBy": {
              "OR": [
                {
                  "friends_SOME": {
                    "username_IN": username,
                  }
                },
                {
                  "username_EQ": username,
                }
              ],
            },
          },
          {
            "likedBy_SOME": {
              "OR": [
                {
                  "friends_SOME": {
                    "username_IN": username,
                  }
                },
                {
                  "username_EQ": username,
                }
              ]
            },
          },
          {
            "usersTagged_SOME": {
              "OR": [
                {
                  "friends_SOME": {
                    "username_IN": username,
                  }
                },
                {
                  "username_IN": username,
                }
              ]
            },
          },
          {
            "comments_SOME": {
              "OR": [
                {
                  "commentBy": {
                    "OR": [
                      {
                        "friends_SOME": {
                          "username_IN": username,
                        },
                      },
                      {
                        "username_EQ": username,
                      }
                    ]
                  },
                },
                {
                  "mentions_SOME": {
                    "OR": [
                      {
                        "username_IN": username,
                      },
                      {
                        "friends_SOME": {
                          "username_IN": username,
                        },
                      },
                      // {
                      //   "likedBy_SOME": {
                      //     "friends_SOME": {
                      //       "username_IN": [username,]
                      //     }
                      //   },
                      // }
                    ],
                  },
                }
              ],
            }
          },
        ],
      }
    };
  }

  // user inbox user details
  static String getUserDetailsForInbox() {
    return """
    query Users(\$where: UserWhere, \$friendsConnectionWhere2: UserFriendsConnectionWhere) {
      users(where: \$where) {
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
    """;
  }

  static Map<String, dynamic> getUserDetailsForInboxVariables(
      List<String> users, String username) {
    return {
      "where": {
        "username_IN": users,
      },
      "friendsConnectionWhere2": {
        "node": {
          "username_EQ": username,
        }
      }
    };
  }
}
