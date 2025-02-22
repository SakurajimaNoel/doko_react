// complete user profile query and variables
import 'package:doko_react/core/config/graphql/graphql_constants.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/comment_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/poll_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';

class GraphqlMutations {
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
                "addedOn": DateTime.now().toIso8601String(),
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
          usersTagged {
            username
          }
        }
      }
    }       
    """;
  }

  static Map<String, dynamic> userCreatePostVariables(PostCreateInput postInput,
      {required List<String> postContent}) {
    return {
      "input": [
        {
          "id": postInput.postId,
          "caption": postInput.caption,
          "content": postContent,
          "likes": 0,
          "createdBy": {
            "connect": {
              "where": {
                "node": {
                  "username_EQ": postInput.username,
                },
              },
            },
          },
          "usersTagged": {
            "connect": [
              {
                "where": {
                  "node": {
                    "username_IN": postInput.usersTagged,
                  }
                }
              }
            ]
          }
        },
      ],
      "where": {
        "username_EQ": postInput.username,
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

  // poll
  static String userAddPollLike() {
    return """
    mutation UpdatePolls(\$where: PollWhere, \$likedByWhere2: UserWhere, \$update: PollUpdateInput) {
      updatePolls(where: \$where, update: \$update) {
        polls {
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

  static Map<String, dynamic> userAddPollLikeVariables({
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

  static String userRemovePollLike() {
    return """
    mutation UpdatePolls(\$where: PollWhere, \$likedByWhere2: UserWhere, \$update: PollUpdateInput) {
      updatePolls(where: \$where, update: \$update) {
        polls {
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

  static Map<String, dynamic> userRemovePollLikeVariables({
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

  // discussion
  static String userAddDiscussionLike() {
    return """
    mutation UpdateDiscussions(\$where: DiscussionWhere, \$likedByWhere2: UserWhere, \$update: DiscussionUpdateInput) {
      updateDiscussions(where: \$where, update: \$update) {
        discussions {
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

  static Map<String, dynamic> userAddDiscussionLikeVariables({
    required String discussionId,
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": discussionId,
      },
      "likedByWhere2": {
        "username_EQ": username,
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

  static String userRemoveDiscussionLike() {
    return """
    mutation UpdateDiscussions(\$where: DiscussionWhere, \$likedByWhere2: UserWhere, \$update: DiscussionUpdateInput) {
      updateDiscussions(where: \$where, update: \$update) {
        discussions {
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

  static Map<String, dynamic> userRemoveDiscussionLikeVariables({
    required String discussionId,
    required String username,
  }) {
    return {
      "where": {
        "id_EQ": discussionId,
      },
      "likedByWhere2": {
        "username_EQ": username,
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
          replyOn {
            id
          }
        }
      }
    }
    ''';
  }

  static Map<String, dynamic> addCommentVariables(
      CommentCreateInput commentInput) {
    String commentOnNode = commentInput.targetNode.nodeName;

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
                    "username_IN": commentInput.content.mentions.toList(
                      growable: false,
                    ),
                  }
                }
              }
            ]
          },
          "replyOn": {
            "connect": {
              "where": {
                "node": {
                  "id_EQ": commentInput.replyOn,
                }
              }
            }
          },
        },
      ],
      "where": {
        "username_EQ": commentInput.username,
      }
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

  // discussion node
  static String userCreateDiscussion() {
    return """
    mutation CreateDiscussions(\$input: [DiscussionCreateInput!]!, \$where: UserWhere) {
      createDiscussions(input: \$input) {
        discussions {
          id
          createdOn
          title
          text
          media
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
          usersTagged {
            username
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> userCreateDiscussionVariables(
    DiscussionCreateInput discussionDetails, {
    required List<String> media,
  }) {
    return {
      "input": [
        {
          "id": discussionDetails.discussionId,
          "title": discussionDetails.title,
          "text": discussionDetails.text,
          "media": media,
          "createdBy": {
            "connect": {
              "where": {
                "node": {
                  "username_EQ": discussionDetails.username,
                },
              }
            }
          },
          "usersTagged": {
            "connect": [
              {
                "where": {
                  "node": {
                    "username_IN": discussionDetails.usersTagged,
                  }
                }
              }
            ]
          }
        }
      ],
      "where": {
        "username_EQ": discussionDetails.username,
      },
    };
  }

  // new poll
  static String userCreatePoll() {
    return """
    mutation CreatePolls(\$input: [PollCreateInput!]!, \$where: UserWhere, \$votesConnectionWhere2: PollVotesConnectionWhere) {
      createPolls(input: \$input) {
        polls {
          id
          createdOn
          usersTagged {
            username
          }
          likedBy(where: \$where) {
            username
          }
          commentsConnection {
            totalCount
          }
          likedByConnection {
            totalCount
          }
          question
          options
          activeFor
          votesAggregate {
            count
          }
          createdBy {
            username
          }
          votesConnection(where: \$votesConnectionWhere2) {
            edges {
              properties {
                addedOn
                option
              }
            }
          }
        }
      }
    }
    """;
  }

  static Map<String, dynamic> userCreatePollVariables(PollCreateInput poll) {
    return {
      "input": [
        {
          "question": poll.question,
          "options": poll.options,
          "activeFor": poll.activeFor,
          "createdBy": {
            "connect": {
              "where": {
                "node": {
                  "username_EQ": poll.username,
                }
              }
            }
          },
          "usersTagged": {
            "connect": [
              {
                "where": {
                  "node": {
                    "username_IN": poll.usersTagged,
                  }
                }
              }
            ]
          }
        }
      ],
      "where": {
        "username_EQ": poll.username,
      },
      "votesConnectionWhere2": {
        "node": {
          "username_EQ": poll.username,
        }
      }
    };
  }
}
