import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/core/global/storage/storage.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  Future<bool> getCompleteUserDetails(
    String username, {
    required String currentUsername,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getCompleteUser()),
          variables: GraphqlQueries.getCompleteUserVariables(
            username,
            currentUsername: currentUsername,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Problem fetching data source.");
      }

      List? res = result.data?["users"];
      Map postRes = result.data?["postsConnection"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(reason: "User doesn't exist.");
      }

      // add in graph
      UserGraph graph = UserGraph();

      CompleteUserEntity user = await CompleteUserEntity.createEntity(
        map: res[0],
      );
      String key = generateUserNodeKey(user.username);
      graph.addEntity(key, user);

      PageInfo info = PageInfo.createEntity(map: postRes["pageInfo"]);
      List postList = postRes["edges"];

      var postFutures = (postList)
          .map((post) => PostEntity.createEntity(map: post["node"]))
          .toList();

      List<PostEntity> posts = await Future.wait(postFutures);
      graph.addPostEntityListToUser(
        user.username,
        newPosts: posts,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> editUserProfile(
      EditProfileInput editDetails, String bucketPath) async {
    try {
      // upload profile to s3
      if (bucketPath.isNotEmpty && bucketPath != editDetails.currentProfile) {
        // new profile
        await uploadFileToAWSByPath(editDetails.newProfile!, bucketPath);

        // delete existing image
        deleteFileFromAWSByPath(editDetails.currentProfile);
      }

      // remove existing profile
      if (bucketPath.isEmpty) {
        deleteFileFromAWSByPath(editDetails.currentProfile);
      }

      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphqlQueries.updateUserProfile()),
          variables: GraphqlQueries.updateUserProfileVariables(
            username: editDetails.username,
            name: editDetails.name,
            bio: editDetails.bio,
            profilePicture: bucketPath,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Can't edit user profile right now.");
      }

      // check if user data is present
      List res = result.data?["updateUsers"]["users"];
      if (res.isEmpty) {
        throw const ApplicationException(
            reason: "Something went wrong when editing user profile.");
      }

      final UserEntity updatedUser = await UserEntity.createEntity(
        map: res[0],
      );
      final UserGraph graph = UserGraph();
      String key = generateUserNodeKey(updatedUser.username);

      final user = graph.getValueByKey(key)! as CompleteUserEntity;
      user.bio = editDetails.bio;
      user.name = updatedUser.name;
      user.profilePicture = updatedUser.profilePicture;

      return true;
    } catch (e) {
      safePrint(e.toString());
      rethrow;
    }
  }

  Future<bool> loadUserProfilePost(UserProfilePostInput postDetails) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphqlQueries.getUserPostsByUsername()),
          variables: GraphqlQueries.getUserPostsByUsernameVariables(
            postDetails.username,
            cursor: postDetails.cursor,
            currentUsername: postDetails.currentUsername,
          ),
        ),
      );

      if (result.hasException) {
        throw ApplicationException(
            reason: result.exception?.graphqlErrors.toString() ??
                "Can't fetch more user posts");
      }

      Map? res = result.data?["postsConnection"];

      if (res == null || res.isEmpty) {
        throw ApplicationException(
          reason: result.exception?.graphqlErrors.toString() ??
              Constants.errorMessage,
        );
      }

      UserGraph graph = UserGraph();

      PageInfo info = PageInfo.createEntity(map: res["pageInfo"]);
      List postList = res["edges"];

      var postFutures = (postList)
          .map((post) => PostEntity.createEntity(map: post["node"]))
          .toList();

      List<PostEntity> posts = await Future.wait(postFutures);
      graph.addPostEntityListToUser(
        postDetails.username,
        newPosts: posts,
        pageInfo: info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
