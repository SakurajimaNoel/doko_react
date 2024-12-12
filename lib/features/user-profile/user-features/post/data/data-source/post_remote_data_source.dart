import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:graphql/client.dart';

class PostRemoteDataSource {
  PostRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;
  final UserGraph graph = UserGraph();

  Future<bool> getPostWithComments(GetPostInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getPostById()),
          variables: GraphqlQueries.getPostByIdVariables(
            details.postId,
            username: details.username,
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

      PostEntity post = await PostEntity.createEntity(map: res[0]);
      String postKey = generatePostNodeKey(post.id);
      graph.addEntity(postKey, post);

      Map commentData = res[0]["commentsConnection"];

      PageInfo info = PageInfo.createEntity(map: commentData["pageInfo"]);
      List commentList = commentData["edges"];

      var commentFutures = (commentList)
          .map(
            (comment) => CommentEntity.createEntity(
              map: comment["node"],
            ),
          )
          .toList();

      List<CommentEntity> comments = await Future.wait(commentFutures);
      graph.addCommentListToPostEntity(
        details.postId,
        comments: comments,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getPostComments(GetCommentsInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getComments(
            true,
            cursor: details.cursor,
          )),
          variables: GraphqlQueries.getCommentsVariable(
            details.nodeId,
            post: true,
            username: details.username,
            cursor: details.cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem loading post comments.");
      }

      Map? commentData = result.data?["commentsConnection"];

      if (commentData == null || commentData.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      PageInfo info = PageInfo.createEntity(map: commentData["pageInfo"]);
      List commentList = commentData["edges"];

      var commentFutures = (commentList)
          .map(
            (comment) => CommentEntity.createEntity(
              map: comment["node"],
            ),
          )
          .toList();

      List<CommentEntity> comments = await Future.wait(commentFutures);
      graph.addCommentListToPostEntity(
        details.nodeId,
        comments: comments,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getCommentReplies(GetCommentsInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getComments(
            false,
            cursor: details.cursor,
          )),
          variables: GraphqlQueries.getCommentsVariable(
            details.nodeId,
            post: false,
            username: details.username,
            cursor: details.cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem loading post comments.");
      }

      Map? commentData = result.data?["commentsConnection"];

      if (commentData == null || commentData.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      PageInfo info = PageInfo.createEntity(map: commentData["pageInfo"]);
      List commentList = commentData["edges"];

      var commentFutures = (commentList)
          .map(
            (comment) => CommentEntity.createEntity(
              map: comment["node"],
            ),
          )
          .toList();

      List<CommentEntity> comments = await Future.wait(commentFutures);

      graph.addCommentListToReply(
        details.nodeId,
        comments: comments,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> searchUserByUsername(
      UserSearchInput searchDetails) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.searchUsersByUsername()),
          variables: GraphqlQueries.searchUsersByUsernameVariables(
            query: searchDetails.query,
            searchDetails.username,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Error loading users right now.");
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        // no search results found
        return [];
      }

      var userFutures = (res)
          .map((user) => UserEntity.createEntity(
                map: user,
              ))
          .toList();

      List<UserEntity> users = await Future.wait(userFutures);
      final UserGraph graph = UserGraph();

      return graph.addUserSearchEntry(users);
    } catch (e) {
      rethrow;
    }
  }
}
