import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:graphql/client.dart';

class PostRemoteDataSource {
  PostRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;
  final UserGraph graph = UserGraph();

  Future<bool> getPostWithComments(GetNodeInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getCompletePostById()),
          variables: GraphqlQueries.getCompletePostByIdVariables(
            details.nodeId,
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
        details.nodeId,
        comments: comments,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getPrimaryNodeComments(GetCommentsInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getComments(
            cursor: details.cursor,
          )),
          variables: GraphqlQueries.getCommentsVariable(
            details.nodeId,
            nodeType: details.nodeType,
            username: details.username,
            cursor: details.cursor,
            latestFirst: details.nodeType != DokiNodeType.comment,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem loading comments.");
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
      if (details.nodeType == DokiNodeType.post) {
        graph.addCommentListToPostEntity(
          details.nodeId,
          comments: comments,
          pageInfo: info,
        );
      }

      if (details.nodeType == DokiNodeType.comment) {
        graph.addCommentListToReply(
          details.nodeId,
          comments: comments,
          pageInfo: info,
        );
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getCommentWithReplies(GetNodeInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getCompleteCommentById()),
          variables: GraphqlQueries.getCompleteCommentByIdVariables(
            details.nodeId,
            username: details.username,
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

      CommentEntity comment = await CommentEntity.createEntity(map: res[0]);
      String commentKey = generateCommentNodeKey(comment.id);
      graph.addEntity(commentKey, comment);

      Map repliesData = res[0]["commentsConnection"];

      PageInfo info = PageInfo.createEntity(map: repliesData["pageInfo"]);
      List repliesList = repliesData["edges"];

      var repliesFuture = (repliesList)
          .map(
            (comment) => CommentEntity.createEntity(
              map: comment["node"],
            ),
          )
          .toList();

      List<CommentEntity> replies = await Future.wait(repliesFuture);

      graph.addCommentListToReply(
        details.nodeId,
        comments: replies,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
