import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/features/User/data/model/friend_model.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserResponse {
  final ResponseStatus status;
  final UserModel? user;

  const UserResponse({
    required this.status,
    this.user,
  });
}

class UsernameResponse {
  final ResponseStatus status;
  final bool available;

  const UsernameResponse({
    required this.status,
    required this.available,
  });
}

class CompleteUserResponse {
  final ResponseStatus status;
  final CompleteUserModel? user;

  const CompleteUserResponse({
    required this.status,
    this.user,
  });
}

class FriendResponse {
  final ResponseStatus status;
  final ProfileFriendInfo? friendInfo;

  const FriendResponse({
    required this.status,
    this.friendInfo,
  });
}

class PostResponse {
  final ResponseStatus status;
  final ProfilePostInfo? postInfo;

  const PostResponse({
    required this.status,
    this.postInfo,
  });
}

class UserGraphqlService {
  late final GraphQLClient _client;

  UserGraphqlService({required GraphQLClient client}) : _client = client;

  Future<UserResponse> getUser(String id) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getUser()),
          variables: UserQueries.getUserVariables(id),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const UserResponse(
          status: ResponseStatus.success,
        );
      }

      UserModel user = await UserModel.createModel(map: res[0]);
      return UserResponse(
        status: ResponseStatus.success,
        user: user,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UserResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<UsernameResponse> checkUsername(String username) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.checkUsername()),
          variables: UserQueries.checkUsernameVariables(username),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const UsernameResponse(
          status: ResponseStatus.success,
          available: true,
        );
      }

      return const UsernameResponse(
        status: ResponseStatus.success,
        available: false,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UsernameResponse(
        status: ResponseStatus.error,
        available: false,
      );
    }
  }

  Future<UserResponse> completeUserProfile(
      CompleteUserProfileVariables userDetails) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.completeUserProfile()),
          variables: UserQueries.completeUserProfileVariables(userDetails),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List res = result.data?["createUsers"]["users"];

      UserModel user = await UserModel.createModel(map: res[0]);

      return UserResponse(
        status: ResponseStatus.success,
        user: user,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UserResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<CompleteUserResponse> getCompleteUser(
    String id, {
    required String currentUserId,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(UserQueries.getCompleteUser()),
          variables: UserQueries.getCompleteUserVariables(
            id,
            currentUserId: currentUserId,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const CompleteUserResponse(
          status: ResponseStatus.success,
        );
      }

      CompleteUserModel user = await CompleteUserModel.createModel(map: res[0]);

      return CompleteUserResponse(
        status: ResponseStatus.success,
        user: user,
      );
    } catch (e) {
      safePrint(e.toString());
      return const CompleteUserResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<FriendResponse> getFriendsByUserId(
    String id,
    String? cursor, {
    required String currentUserId,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getFriendsByUserId(cursor)),
          variables: UserQueries.getFriendsByUserIdVariables(
            id,
            cursor,
            currentUserId: currentUserId,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const FriendResponse(
          status: ResponseStatus.success,
        );
      }

      ProfileFriendInfo info = await ProfileFriendInfo.createModel(
        map: res[0]["friendsConnection"],
      );

      return FriendResponse(
        status: ResponseStatus.success,
        friendInfo: info,
      );
    } catch (e) {
      safePrint(e.toString());
      return const FriendResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<PostResponse> getPostsByUserId(String id, String cursor) async {
    try {
      final AuthenticationActions auth =
          AuthenticationActions(auth: Amplify.Auth);

      var userIdResult = await auth.getUserId();
      if (userIdResult.status == AuthStatus.error) {
        throw Exception(userIdResult.message);
      }

      String userId = userIdResult.message!;

      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getUserPostsByUserId()),
          variables:
              UserQueries.getUserPostsByUserIdVariables(id, cursor, userId),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const PostResponse(
          status: ResponseStatus.success,
        );
      }

      ProfilePostInfo info = await ProfilePostInfo.createModel(
        map: res[0]["postsConnection"],
      );

      return PostResponse(
        status: ResponseStatus.success,
        postInfo: info,
      );
    } catch (e) {
      safePrint(e.toString());
      return const PostResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<FriendResponse> getPendingOutgoingFriendsByUserId(
      String id, String? cursor) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getPendingOutgoingFriendsByUserId(cursor)),
          variables: UserQueries.getPendingOutgoingFriendsByUserIdVariables(
              id, cursor),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const FriendResponse(
          status: ResponseStatus.success,
        );
      }

      ProfileFriendInfo info = await ProfileFriendInfo.createModel(
        map: res[0]["friendsConnection"],
      );

      return FriendResponse(
        status: ResponseStatus.success,
        friendInfo: info,
      );
    } catch (e) {
      safePrint(e.toString());
      return const FriendResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<FriendResponse> getPendingIncomingFriendsByUserId(
      String id, String? cursor) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getPendingIncomingFriendsByUserId(cursor)),
          variables: UserQueries.getPendingIncomingFriendsByUserIdVariables(
              id, cursor),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const FriendResponse(
          status: ResponseStatus.success,
        );
      }

      ProfileFriendInfo info = await ProfileFriendInfo.createModel(
        map: res[0]["friendsConnection"],
      );

      return FriendResponse(
        status: ResponseStatus.success,
        friendInfo: info,
      );
    } catch (e) {
      safePrint(e.toString());
      return const FriendResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<UserResponse> updateUserProfile(
      String id, String name, String bio, String profilePicture) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.updateUserProfile()),
          variables: UserQueries.updateUserProfileVariables(
              id, name, bio, profilePicture),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List res = result.data?["updateUsers"]["users"];

      UserModel user = await UserModel.createModel(map: res[0]);

      return UserResponse(
        status: ResponseStatus.success,
        user: user,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UserResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<ResponseStatus> userSendFriendRequest(
      String requestedBy, String requestedTo) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userSendFriendRequest()),
          variables: UserQueries.userSendFriendRequestVariables(
              requestedBy, requestedTo),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      return ResponseStatus.success;
    } catch (e) {
      safePrint(e.toString());
      return ResponseStatus.error;
    }
  }

  Future<ResponseStatus> userAcceptFriendRequest(
      String requestedBy, String requestedTo) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userAcceptFriendRequest()),
          variables: UserQueries.userAcceptFriendRequestVariables(
              requestedBy, requestedTo),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      return ResponseStatus.success;
    } catch (e) {
      safePrint(e.toString());
      return ResponseStatus.error;
    }
  }

  Future<ResponseStatus> userRemoveFriendRelation(
      String requestedBy, String requestedTo) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userRemoveFriendRelation()),
          variables: UserQueries.userRemoveFriendRelationVariables(
              requestedBy, requestedTo),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      return ResponseStatus.success;
    } catch (e) {
      safePrint(e.toString());
      return ResponseStatus.error;
    }
  }

  Future<ResponseStatus> userCreatePost({
    required String caption,
    required List<String> content,
  }) async {
    try {
      final AuthenticationActions auth =
          AuthenticationActions(auth: Amplify.Auth);

      var userIdResult = await auth.getUserId();
      if (userIdResult.status == AuthStatus.error) {
        throw Exception(userIdResult.message);
      }

      String userId = userIdResult.message!;

      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userCreatePost()),
          variables: UserQueries.userCreatePostVariables(
            userId: userId,
            caption: caption,
            content: content,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      return ResponseStatus.success;
    } catch (e) {
      safePrint(e.toString());
      return ResponseStatus.error;
    }
  }

  Future<ResponseStatus> userLikePostAction({
    required String postId,
    bool addLike = true,
  }) async {
    try {
      final AuthenticationActions auth =
          AuthenticationActions(auth: Amplify.Auth);

      var userIdResult = await auth.getUserId();
      if (userIdResult.status == AuthStatus.error) {
        throw Exception(userIdResult.message);
      }

      String userId = userIdResult.message!;

      Future<QueryResult<Object?>> futureMutation;

      if (addLike) {
        futureMutation = _client.mutate(
          MutationOptions(
            document: gql(UserQueries.userAddLikePost()),
            variables: UserQueries.userAddLikePostVariables(
              postId: postId,
              userId: userId,
            ),
          ),
        );
      } else {
        futureMutation = _client.mutate(
          MutationOptions(
            document: gql(UserQueries.userRemoveLikePost()),
            variables: UserQueries.userRemoveLikePostVariables(
              postId: postId,
              userId: userId,
            ),
          ),
        );
      }

      QueryResult result = await futureMutation;

      if (result.hasException) {
        throw Exception(result.exception);
      }

      return ResponseStatus.success;
    } catch (e) {
      safePrint(e.toString());
      return ResponseStatus.error;
    }
  }
}
