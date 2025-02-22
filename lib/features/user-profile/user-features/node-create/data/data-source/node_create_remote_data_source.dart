import 'package:doko_react/core/config/graphql/mutations/graphql_mutations.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/cache/cache.dart';
import 'package:doko_react/core/global/storage/storage.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/discussion/discussion_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/comment_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/poll_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';
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
            postDetails,
            postContent: uploadedPostMediaContent,
          ),
        ),
      );

      if (result.hasException) {
        // clean up
        for (String path in uploadedPostMediaContent) {
          deleteFileFromAWSByPath(path);
        }

        throw const ApplicationException(
          reason: "Problem uploading post.",
        );
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

        throw const ApplicationException(
          reason: "Problem adding comment.",
        );
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
      graph.addCommentToPrimaryNode(
        commentDetails.targetNode.keyGenerator(commentDetails.targetNodeId),
        comment: newComment,
      );

      return newComment.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createNewDiscussion(
      DiscussionCreateInput discussionDetails) async {
    try {
      // upload media items to aws
      List<Future<String>> fileUploadFuture = [];
      for (final item in discussionDetails.media) {
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
      List<String> uploadedDiscussionMediaContent =
          await Future.wait(fileUploadFuture);
      if (discussionDetails.media.isNotEmpty &&
          uploadedDiscussionMediaContent.isEmpty) {
        throw const ApplicationException(
          reason:
              "Oops! Something went wrong when uploading media items. Please try again later.",
        );
      }

      // update graph
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userCreateDiscussion()),
          variables: GraphqlMutations.userCreateDiscussionVariables(
            discussionDetails,
            media: uploadedDiscussionMediaContent,
          ),
        ),
      );

      if (result.hasException) {
        // clean up
        for (String path in uploadedDiscussionMediaContent) {
          deleteFileFromAWSByPath(path);
        }

        throw const ApplicationException(
          reason: "Problem creating discussion.",
        );
      }

      List? res = result.data?["createDiscussions"]["discussions"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      DiscussionEntity newDiscussion =
          await DiscussionEntity.createEntity(map: res[0]);
      final UserGraph graph = UserGraph();

      graph.addDiscussionEntityToUser(
          discussionDetails.username, newDiscussion);

      return newDiscussion.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createNewPoll(PollCreateInput pollDetails) async {
    try {
      // update graph
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlMutations.userCreatePoll()),
          variables: GraphqlMutations.userCreatePollVariables(pollDetails),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Problem creating poll.",
        );
      }

      List? res = result.data?["createPolls"]["polls"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      PollEntity newPoll = await PollEntity.createEntity(map: res[0]);

      final UserGraph graph = UserGraph();

      graph.addPollEntityToUser(pollDetails.username, newPoll);

      return newPoll.id;
    } catch (e) {
      print(e);
      print("error here");
      rethrow;
    }
  }
}
