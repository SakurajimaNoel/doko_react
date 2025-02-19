import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/config/graphql/mutations/graphql_mutations.dart';
import 'package:doko_react/core/config/graphql/queries/graphql_queries.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/core/global/storage/storage.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:graphql/client.dart';

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
          reason: "Problem getting \"@$username's\" profile.",
        );
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
          document: gql(GraphqlMutations.updateUserProfile()),
          variables: GraphqlMutations.updateUserProfileVariables(
            username: editDetails.username,
            name: editDetails.name,
            bio: editDetails.bio,
            profilePicture: bucketPath,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Can't edit user profile right now.",
        );
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

  Future<bool> loadUserProfilePost(UserProfileNodesInput postDetails) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getUserPostsByUsername()),
          variables: GraphqlQueries.getUserPostsByUsernameVariables(
            postDetails.username,
            cursor: postDetails.cursor,
            currentUsername: postDetails.currentUsername,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
          reason: "Can't fetch more user posts",
        );
      }

      Map? res = result.data?["postsConnection"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
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

  Future<bool> getUserProfileFriends(
      UserProfileNodesInput friendsDetails) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document:
              gql(GraphqlQueries.getFriendsByUsername(friendsDetails.cursor)),
          variables: GraphqlQueries.getFriendsByUsernameVariables(
            friendsDetails.username,
            cursor: friendsDetails.cursor,
            currentUsername: friendsDetails.currentUsername,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
            reason: "Can't fetch more user friends");
      }

      Map? res = result.data?["users"][0]["friendsConnection"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      UserGraph graph = UserGraph();

      PageInfo info = PageInfo.createEntity(map: res["pageInfo"]);
      List userList = res["edges"];

      var userFutures = (userList)
          .map((user) => UserEntity.createEntity(map: user["node"]))
          .toList();

      List<UserEntity> users = await Future.wait(userFutures);

      if (friendsDetails.cursor.isEmpty) {
        /// when cursor is empty
        /// it means first time fetching
        /// or refresh so reset the friends of user
        /// so reset the friends
        String userKey = generateUserNodeKey(friendsDetails.username);
        final user = graph.getValueByKey(userKey)! as CompleteUserEntity;

        user.friends = Nodes.empty();
      }
      graph.addUserFriendsListToUser(
        friendsDetails.username,
        pageInfo: info,
        newUsers: users,
      );

      return true;
    } catch (e) {
      print("error here");
      print(e);
      rethrow;
    }
  }

  // this will return list of keys
  Future<List<String>> searchUserByNameOrUsername(
      UserSearchInput searchDetails) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.searchUserByUsernameOrName()),
          variables: GraphqlQueries.searchUserByUsernameOrNameVariables(
            searchDetails.query,
            username: searchDetails.username,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Can't search right now.");
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

  Future<List<String>> searchUserFriendsByNameOrUsername(
      UserFriendsSearchInput searchDetails) async {
    try {
      final UserGraph graph = UserGraph();
      final String key = generateUserNodeKey(searchDetails.username);
      final user = graph.getValueByKey(key)! as CompleteUserEntity;

      if (user.friends.isNotEmpty && !user.friends.pageInfo.hasNextPage) {
        /// we have all the friends fetched
        /// so just filter the required results
        /// from the friends
        final filteredUsers = user.friends.items.where((String userKey) {
          final userItem = graph.getValueByKey(userKey)! as UserEntity;

          return userItem.username.contains(searchDetails.query) ||
              userItem.name.contains(searchDetails.query);
        }).toList();

        return filteredUsers;
      }

      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.searchUserFriendsByUsernameOrName()),
          variables: GraphqlQueries.searchUserFriendsByUsernameOrNameVariables(
            searchDetails.username,
            currentUsername: searchDetails.currentUsername,
            query: searchDetails.query,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(reason: "Can't search right now.");
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        // no search results found
        return [];
      }

      var friends = res[0]["friendsConnection"]["edges"] as List;

      var userFutures = (friends)
          .map((user) => UserEntity.createEntity(map: user["node"]))
          .toList();

      List<UserEntity> users = await Future.wait(userFutures);

      return graph.addUserSearchEntry(users);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getUserPendingIncomingFriendRequests(
      UserProfileNodesInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getPendingIncomingFriendsByUsername(
              details.cursor)),
          variables:
              GraphqlQueries.getPendingIncomingFriendsByUsernameVariables(
            details.username,
            cursor: details.cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
            reason: "Can't fetch user pending incoming requests.");
      }

      Map? res = result.data?["users"][0]["friendsConnection"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      UserGraph graph = UserGraph();

      PageInfo info = PageInfo.createEntity(map: res["pageInfo"]);
      List userList = res["edges"];

      var userFutures = (userList)
          .map((user) => UserEntity.createEntity(map: user["node"]))
          .toList();

      List<UserEntity> users = await Future.wait(userFutures);

      if (details.cursor.isEmpty) {
        /// when cursor is empty
        /// it means first time fetching
        /// or refresh so reset the friends of user
        /// so reset the friends
        String key = generatePendingIncomingReqKey();
        graph.addEntity(key, Nodes.empty());
      }
      graph.addPendingIncomingRequests(
        users,
        info,
      );

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getUserPendingOutgoingFriendRequests(
      UserProfileNodesInput details) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(GraphqlQueries.getPendingOutgoingFriendsByUsername(
              details.cursor)),
          variables:
              GraphqlQueries.getPendingOutgoingFriendsByUsernameVariables(
            details.username,
            cursor: details.cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw const ApplicationException(
            reason: "Can't fetch user pending outgoing requests.");
      }

      Map? res = result.data?["users"][0]["friendsConnection"];

      if (res == null || res.isEmpty) {
        throw const ApplicationException(
          reason: Constants.errorMessage,
        );
      }

      UserGraph graph = UserGraph();

      PageInfo info = PageInfo.createEntity(map: res["pageInfo"]);
      List userList = res["edges"];

      var userFutures = (userList)
          .map((user) => UserEntity.createEntity(map: user["node"]))
          .toList();

      List<UserEntity> users = await Future.wait(userFutures);

      if (details.cursor.isEmpty) {
        /// when cursor is empty
        /// it means first time fetching
        /// or refresh so reset the friends of user
        /// so reset the friends
        String key = generatePendingOutgoingReqKey();
        graph.addEntity(key, Nodes.empty());
      }
      graph.addPendingOutgoingRequests(
        users,
        info,
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
        throw const ApplicationException(
          reason: "Error getting users right now.",
        );
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
