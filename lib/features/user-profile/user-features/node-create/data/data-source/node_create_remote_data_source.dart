import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/cache/cache.dart';
import 'package:doko_react/core/global/storage/storage.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class NodeCreateRemoteDataSource {
  const NodeCreateRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  Future<bool> createNewPost(PostCreateInput postDetails) async {
    try {
      // upload media items to aws
      List<Future<String>> fileUploadFuture = [];
      for (final item in postDetails.content) {
        if (item.type == MediaTypeValue.thumbnail ||
            item.type == MediaTypeValue.unknown) continue;

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
          document: gql(GraphqlQueries.userCreatePost()),
          variables: GraphqlQueries.userCreatePostVariables(
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
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
