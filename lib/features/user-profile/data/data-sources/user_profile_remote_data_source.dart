import 'package:doko_react/core/config/graphql/mutations/graphql_mutations.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
import 'package:doko_react/features/user-profile/data/models/comments/comment_action_model.dart';
import 'package:doko_react/features/user-profile/data/models/post/post_action_model.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
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
        throw ApplicationException(
          reason: result.exception?.graphqlErrors.toString() ??
              "Problem adding user like",
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
        throw ApplicationException(
          reason: result.exception?.graphqlErrors.toString() ??
              "Problem removing user like",
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
          reason: result.exception?.graphqlErrors.toString() ??
              "Can't send friend request to ${relationDetails.username}.",
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
          reason: result.exception?.graphqlErrors.toString() ??
              "Can't accept friend request of ${relationDetails.username}.",
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
        throw ApplicationException(
          reason: result.exception?.graphqlErrors.toString() ??
              Constants.errorMessage,
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
        throw ApplicationException(
          reason: result.exception?.graphqlErrors.toString() ??
              "Problem adding user like",
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
        throw ApplicationException(
          reason: result.exception?.graphqlErrors.toString() ??
              "Problem removing user like",
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
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem loading post.");
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
      if (graph.containsKey(postKey)) {
        final existsPost = graph.getValueByKey(postKey)! as PostEntity;

        existsPost.updateCommentsCount(post.commentsCount);
        existsPost.updateUserLikes(post.userLike, post.likesCount);

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
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem loading comment.");
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
      graph.addEntity(comment.id, comment);

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
