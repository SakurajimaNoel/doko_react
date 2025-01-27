import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/config/graphql/mutations/graphql_mutations.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/cache/cache.dart';
import 'package:doko_react/core/global/storage/storage.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:graphql/client.dart';

class NodeCreateRemoteDataSource {
  const NodeCreateRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  Future<String> createNewPost(PostCreateInput postDetails) async {
    try {
      // upload media items to aws
      List<Future<String>> fileUploadFuture = [];
      for (final item in postDetails.content) {
        if (item.type == MediaTypeValue.thumbnail ||
            item.type == MediaTypeValue.unknown) {
          continue;
        }

        fileUploadFuture.add(uploadFileToAWSByPath(
          item.file!,
          item.bucketPath,
        ));
        addFileToCache(item.file!, item.bucketPath);
      }
      List<String> uploadedPostMediaContent =
          await Future.wait(fileUploadFuture);
      if (postDetails.content.isNotEmpty && uploadedPostMediaContent.isEmpty) {
        throw const ApplicationException(
          reason:
              "Oops! Something went wrong when uploading media items. Please try again later.",
        );
      }

      // update graph
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userCreatePost()),
          variables: GraphqlMutations.userCreatePostVariables(
            postDetails.postId,
            username: postDetails.username,
            caption: postDetails.caption,
            content: uploadedPostMediaContent,
          ),
        ),
      );

      if (result.hasException) {
        // clean up
        for (String path in uploadedPostMediaContent) {
          deleteFileFromAWSByPath(path);
        }

        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem uploading post.");
      }

      List? res = result.data?["createPosts"]["posts"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      PostEntity newPost = await PostEntity.createEntity(map: res[0]);
      final UserGraph graph = UserGraph();

      graph.addPostEntityToUser(postDetails.username, newPost);
      return newPost.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createComment(CommentCreateInput commentDetails) async {
    try {
      // handle media
      if (commentDetails.media != null) {
        if (commentDetails.media!.extension != "uri") {
          // upload to bucket
          await uploadFileBytesToAWSByPath(
              commentDetails.media!.data!, commentDetails.bucketPath!);
        }
      }

      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.addComment()),
          variables: GraphqlMutations.addCommentVariables(commentDetails),
        ),
      );

      if (result.hasException) {
        if (commentDetails.bucketPath != null) {
          deleteFileFromAWSByPath(commentDetails.bucketPath!);
        }

        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem adding comment.");
      }

      List? comment = result.data?["createComments"]["comments"];

      if (comment == null || comment.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      CommentEntity newComment = await CommentEntity.createEntity(
        map: comment[0],
      );

      final UserGraph graph = UserGraph();
      if (commentDetails.targetNode == CommentTarget.post) {
        // add to post
        graph.addCommentToPostEntity(
          commentDetails.targetNodeId,
          comment: newComment,
        );
      } else {
        graph.addReplyToCommentEntity(
          commentDetails.targetNodeId,
          comment: newComment,
        );
      }

      return newComment.id;
    } catch (e) {
      safePrint("error message");
      safePrint(e.toString());
      rethrow;
    }
  }
}
