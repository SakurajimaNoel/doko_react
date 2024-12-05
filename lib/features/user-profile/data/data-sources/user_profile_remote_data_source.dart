import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/user-profile/data/models/post/post_action_model.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
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
      String postKey = generatePostNodeKey(postId);

      PostEntity post = graph.getValueByKey(postKey)! as PostEntity;
      post.updateUserLikes(model.userLike, model.likesCount);
      post.updateCommentsCount(model.commentsCount);

      graph.addEntity(postKey, post);

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
      String postKey = generatePostNodeKey(postId);

      PostEntity post = graph.getValueByKey(postKey)! as PostEntity;
      post.updateUserLikes(model.userLike, model.likesCount);
      post.updateCommentsCount(model.commentsCount);

      graph.addEntity(postKey, post);

      return true;
    } catch (_) {
      rethrow;
    }
  }
}
