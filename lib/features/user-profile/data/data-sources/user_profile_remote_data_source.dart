import 'package:doko_react/core/config/graphql/mutations/graphql_mutations.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
import 'package:doko_react/features/user-profile/data/models/comments/comment_action_model.dart';
import 'package:doko_react/features/user-profile/data/models/post/post_action_model.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/discussion/discussion_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:graphql/client.dart';

class UserProfileRemoteDataSource {
  const UserProfileRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  Future<bool> userAddPostLike(String postId, String username) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userAddLikePost()),
          variables: GraphqlMutations.userAddLikePostVariables(
            postId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem adding user like",
        );
      }

      List? res = result.data?["updatePosts"]["posts"];
      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      PostActionModel model = PostActionModel.createModel(res[0]);
      UserGraph graph = UserGraph();

      graph.handleUserLikeActionForPostEntity(
        postId,
        userLike: model.userLike,
        likesCount: model.likesCount,
        commentsCount: model.commentsCount,
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> userRemovePostLike(String postId, String username) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userRemoveLikePost()),
          variables: GraphqlMutations.userRemoveLikePostVariables(
            postId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem removing user like",
        );
      }

      List? res = result.data?["updatePosts"]["posts"];
      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      PostActionModel model = PostActionModel.createModel(res[0]);
      UserGraph graph = UserGraph();

      graph.handleUserLikeActionForPostEntity(
        postId,
        userLike: model.userLike,
        likesCount: model.likesCount,
        commentsCount: model.commentsCount,
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> userCreateFriendRelation(
      UserToUserRelationDetails relationDetails) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userCreateFriendRelation()),
          variables: GraphqlMutations.userCreateFriendRelationVariables(
              relationDetails),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
          reason: "Can't send friend request to ${relationDetails.username}.",
        );
      }

      List? res = result.data?["updateUsers"]["users"];
      if (res == null || res.isEmpty) {
        throw ApplicationException(
          reason: "Can't send friend request to ${relationDetails.username}.",
        );
      }

      UserRelationInfo? relationInfo = UserEntity.getRelationInfo(res[0]);
      UserGraph graph = UserGraph();

      graph.sendRequest(
        relationDetails.currentUsername,
        friendUsername: relationDetails.username,
        relationInfo: relationInfo,
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> userAcceptFriendRelation(
      UserToUserRelationDetails relationDetails) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userAcceptFriendRelation()),
          variables: GraphqlMutations.userAcceptFriendRelationVariables(
              relationDetails),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
          reason: "Can't accept friend request of ${relationDetails.username}.",
        );
      }

      List? res = result.data?["updateUsers"]["users"];
      if (res == null || res.isEmpty) {
        throw ApplicationException(
          reason: "Can't accept friend request of ${relationDetails.username}.",
        );
      }

      UserRelationInfo? relationInfo = UserEntity.getRelationInfo(res[0]);
      UserGraph graph = UserGraph();

      graph.addFriendToUser(
        relationDetails.currentUsername,
        friendUsername: relationDetails.username,
        relationInfo: relationInfo,
      );

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> userRemoveFriendRelation(
      UserToUserRelationDetails relationDetails) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userRemoveFriendRelation()),
          variables: GraphqlMutations.userRemoveFriendRelationVariables(
              relationDetails),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      List? res = result.data?["updateUsers"]["users"];
      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      // UserRelationInfo? relationInfo = UserEntity.getRelationInfo(res[0]);
      UserGraph graph = UserGraph();

      graph.removeFriend(
          relationDetails.currentUsername, relationDetails.username);

      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> userAddCommentLike(String commentId, String username) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userAddLikeComment()),
          variables: GraphqlMutations.userAddCommentLikeVariables(
            commentId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem adding user like",
        );
      }

      List? res = result.data?["updateComments"]["comments"];
      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      CommentActionModel model = CommentActionModel.createModel(res[0]);
      UserGraph graph = UserGraph();

      graph.handleUserLikeActionForCommentEntity(
        commentId,
        userLike: model.userLike,
        likesCount: model.likesCount,
        commentsCount: model.commentsCount,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> userRemoveCommentLike(String commentId, String username) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userRemoveCommentLike()),
          variables: GraphqlMutations.userRemoveCommentLikeVariables(
            commentId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem removing user like",
        );
      }

      List? res = result.data?["updateComments"]["comments"];
      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      CommentActionModel model = CommentActionModel.createModel(res[0]);
      UserGraph graph = UserGraph();

      graph.handleUserLikeActionForCommentEntity(
        commentId,
        userLike: model.userLike,
        likesCount: model.likesCount,
        commentsCount: model.commentsCount,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getUserByUsername(String username, String currentUser) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getUserByUsername()),
          variables: GraphqlQueries.getUserByUsernameVariables(
            username,
            currentUser: currentUser,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];
      if (res == null || res.isEmpty) {
        throw const ApplicationException(reason: "User doesn't exist.");
      }

      // add in graph
      UserGraph graph = UserGraph();
      UserEntity user = await UserEntity.createEntity(
        map: res[0],
      );

      String key = generateUserNodeKey(user.username);
      graph.addEntity(key, user);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getPostById(String postId, String username) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getPostById()),
          variables: GraphqlQueries.getPostByIdVariables(
            postId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Problem loading post.");
      }

      List? res = result.data?["posts"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: "Post doesn't exist.",
        );
      }

      // add in graph
      UserGraph graph = UserGraph();
      PostEntity post = await PostEntity.createEntity(map: res[0]);
      String postKey = generatePostNodeKey(post.id);

      // this condition shouldn't exist
      if (graph.containsKey(postKey)) {
        final existsPost = graph.getValueByKey(postKey)! as PostEntity;

        existsPost.updateCommentsCount(post.commentsCount);
        existsPost.updateLikeCount(post.likesCount);
        existsPost.updateUserLikeStatus(post.userLike);

        graph.addEntity(postKey, existsPost);
      } else {
        graph.addEntity(postKey, post);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getCommentById(String commentId, String username) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getCommentById()),
          variables: GraphqlQueries.getCommentByIdVariables(
            commentId: commentId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Problem loading comment.");
      }

      List? res = result.data?["comments"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: "Comment doesn't exist.",
        );
      }

      CommentEntity comment = await CommentEntity.createEntity(
        map: res[0],
      );

      UserGraph graph = UserGraph();
      graph.addEntity(generateCommentNodeKey(comment.id), comment);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getDiscussionById(String discussionId, String username) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getDiscussionById()),
          variables: GraphqlQueries.getDiscussionByIdVariables(
            discussionId: discussionId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Problem loading discussion.");
      }

      List? res = result.data?["discussions"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: "Discussion doesn't exist.",
        );
      }

      // add in graph
      UserGraph graph = UserGraph();
      DiscussionEntity discussion =
          await DiscussionEntity.createEntity(map: res[0]);
      String discussionKey = generateDiscussionNodeKey(discussion.id);

      // this condition shouldn't exist
      if (graph.containsKey(discussionKey)) {
        final existsDiscussion =
            graph.getValueByKey(discussionKey)! as DiscussionEntity;

        existsDiscussion.updateCommentsCount(discussion.commentsCount);
        existsDiscussion.updateLikeCount(discussion.likesCount);
        existsDiscussion.updateUserLikeStatus(discussion.userLike);

        graph.addEntity(discussionKey, existsDiscussion);
      } else {
        graph.addEntity(discussionKey, discussion);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getPollById(String pollId, String username) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getPollById()),
          variables: GraphqlQueries.getPollByIdVariables(
            pollId: pollId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Problem loading poll.");
      }

      List? res = result.data?["polls"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: "Poll doesn't exist.",
        );
      }

      // add in graph
      UserGraph graph = UserGraph();
      PollEntity poll = await PollEntity.createEntity(map: res[0]);
      String pollKey = generatePollNodeKey(poll.id);

      if (graph.containsKey(pollKey)) {
        final existPoll = graph.getValueByKey(pollKey)! as PollEntity;

        existPoll.updateCommentsCount(poll.commentsCount);
        existPoll.updateLikeCount(poll.likesCount);
        existPoll.updateUserLikeStatus(poll.userLike);

        graph.addEntity(pollKey, existPoll);
      } else {
        graph.addEntity(pollKey, poll);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
