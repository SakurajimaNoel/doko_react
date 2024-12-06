import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
import 'package:doko_react/features/user-profile/data/models/post/post_action_model.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserProfileRemoteDataSource {
  const UserProfileRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  Future<bool> userAddPostLike(String postId, String username) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlQueries.userAddLikePost()),
          variables: GraphqlQueries.userAddLikePostVariables(
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
          document: gql(GraphqlQueries.userRemoveLikePost()),
          variables: GraphqlQueries.userRemoveLikePostVariables(
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
          document: gql(GraphqlQueries.userCreateFriendRelation()),
          variables:
              GraphqlQueries.userCreateFriendRelationVariables(relationDetails),
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

      graph.sendRequest(relationDetails.username, relationInfo);

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
          document: gql(GraphqlQueries.userAcceptFriendRelation()),
          variables:
              GraphqlQueries.userAcceptFriendRelationVariables(relationDetails),
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
          document: gql(GraphqlQueries.userRemoveFriendRelation()),
          variables:
              GraphqlQueries.userRemoveFriendRelationVariables(relationDetails),
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
}
