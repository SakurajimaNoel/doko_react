import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/archive/features/User/data/model/comment_model.dart';
import 'package:doko_react/archive/features/User/data/model/friend_model.dart';
import 'package:doko_react/archive/features/User/data/model/model.dart';
import 'package:doko_react/archive/features/User/data/model/post_model.dart';
import 'package:doko_react/archive/features/User/data/model/user_model.dart';
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

  // final CompleteUserModel? user;

  const CompleteUserResponse({
    required this.status,
    // this.user,
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

class SearchResponse {
  final ResponseStatus status;
  final List<FriendUserModel> users;

  const SearchResponse({
    required this.status,
    this.users = const [],
  });
}

class IndividualPostResponse {
  final ResponseStatus status;
  final PostModel? postInfo;
  final CommentInfo? commentInfo;

  const IndividualPostResponse({
    required this.status,
    this.postInfo,
    this.commentInfo,
  });
}

class CommentUserSearchResponse {
  final ResponseStatus status;
  final List<UserModel> users;

  const CommentUserSearchResponse({
    required this.status,
    this.users = const [],
  });
}

class CommentResponse {
  final ResponseStatus status;
  final CommentInfo? commentInfo;

  const CommentResponse({
    required this.status,
    this.commentInfo,
  });
}

class UserGraphqlService {
  late final GraphQLClient _client;

  UserGraphqlService({required GraphQLClient client}) : _client = client;

  Future<UserResponse> getUser(String id) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
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

      UserModel user = UserModel.createModelInfo(map: res[0]);
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

  // Future<UsernameResponse> checkUsername(String username) async {
  //   try {
  //     QueryResult result = await _client.query(
  //       QueryOptions(
  //         fetchPolicy: FetchPolicy.networkOnly,
  //         document: gql(UserQueries.checkUsername()),
  //         variables: UserQueries.checkUsernameVariables(username),
  //       ),
  //     );
  //
  //     if (result.hasException) {
  //       throw Exception(result.exception);
  //     }
  //
  //     List? res = result.data?["users"];
  //
  //     if (res == null || res.isEmpty) {
  //       return const UsernameResponse(
  //         status: ResponseStatus.success,
  //         available: true,
  //       );
  //     }
  //
  //     return const UsernameResponse(
  //       status: ResponseStatus.success,
  //       available: false,
  //     );
  //   } catch (e) {
  //     safePrint(e.toString());
  //     return const UsernameResponse(
  //       status: ResponseStatus.error,
  //       available: false,
  //     );
  //   }
  // }

  // Future<UserResponse> completeUserProfile(
  //     CompleteUserProfileVariables userDetails) async {
  //   try {
  //     QueryResult result = await _client.mutate(
  //       MutationOptions(
  //         document: gql(UserQueries.completeUserProfile()),
  //         variables: UserQueries.completeUserProfileVariables(userDetails),
  //       ),
  //     );
  //
  //     if (result.hasException) {
  //       throw Exception(result.exception);
  //     }
  //
  //     List res = result.data?["createUsers"]["users"];
  //
  //     UserModel user = await UserModel.createModel(map: res[0]);
  //
  //     return UserResponse(
  //       status: ResponseStatus.success,
  //       user: user,
  //     );
  //   } catch (e) {
  //     safePrint(e.toString());
  //     return const UserResponse(
  //       status: ResponseStatus.error,
  //     );
  //   }
  // }

  // Future<CompleteUserResponse> getCompleteUser(
  //   String username, {
  //   required String currentUsername,
  // }) async {
  //   try {
  //     QueryResult result = await _client.query(
  //       QueryOptions(
  //         fetchPolicy: FetchPolicy.networkOnly,
  //         document: gql(UserQueries.getCompleteUser()),
  //         variables: UserQueries.getCompleteUserVariables(
  //           username,
  //           currentUsername: currentUsername,
  //         ),
  //       ),
  //     );
  //
  //     if (result.hasException) {
  //       throw Exception(result.exception);
  //     }
  //
  //     List? res = result.data?["users"];
  //
  //     if (res == null || res.isEmpty) {
  //       return const CompleteUserResponse(
  //         status: ResponseStatus.success,
  //       );
  //     }
  //
  //     CompleteUserModel user = await CompleteUserModel.createModel(map: res[0]);
  //
  //     return CompleteUserResponse(
  //       status: ResponseStatus.success,
  //       user: user,
  //     );
  //   } catch (e) {
  //     safePrint(e.toString());
  //     return const CompleteUserResponse(
  //       status: ResponseStatus.error,
  //     );
  //   }
  // }

  Future<FriendResponse> getFriendsByUsername(
    String username, {
    String? cursor,
    required String currentUsername,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(UserQueries.getFriendsByUsername(cursor)),
          variables: UserQueries.getFriendsByUsernameVariables(
            username,
            cursor: cursor,
            currentUsername: currentUsername,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return FriendResponse(
          status: ResponseStatus.success,
          friendInfo: ProfileFriendInfo(
            friends: [],
            info: NodeInfo(
              endCursor: null,
              hasNextPage: false,
            ),
          ),
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

  Future<PostResponse> getPostsByUsername(
    String username, {
    required String cursor,
    required String currentUsername,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getUserPostsByUsername()),
          variables: UserQueries.getUserPostsByUsernameVariables(
            username,
            currentUsername: currentUsername,
            cursor: cursor,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      Map? res = result.data;

      if (res == null || res.isEmpty) {
        return const PostResponse(
          status: ResponseStatus.success,
        );
      }

      ProfilePostInfo info = await ProfilePostInfo.createModel(
        map: res["postsConnection"],
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

  Future<FriendResponse> getPendingOutgoingFriendsByUsername(
    String username, {
    String? cursor,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document:
              gql(UserQueries.getPendingOutgoingFriendsByUsername(cursor)),
          variables: UserQueries.getPendingOutgoingFriendsByUsernameVariables(
            username,
            cursor: cursor,
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

  Future<FriendResponse> getPendingIncomingFriendsByUsername(
    String username, {
    String? cursor,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document:
              gql(UserQueries.getPendingIncomingFriendsByUsername(cursor)),
          variables: UserQueries.getPendingIncomingFriendsByUsernameVariables(
            username,
            cursor: cursor,
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

  Future<UserResponse> updateUserProfile({
    required String username,
    required String name,
    required String bio,
    required String profilePicture,
  }) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.updateUserProfile()),
          variables: UserQueries.updateUserProfileVariables(
            username: username,
            name: name,
            bio: bio,
            profilePicture: profilePicture,
          ),
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

  Future<ResponseStatus> userSendFriendRequest({
    required String requestedByUsername,
    required String requestedToUsername,
  }) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userSendFriendRequest()),
          variables: UserQueries.userSendFriendRequestVariables(
            requestedByUsername: requestedByUsername,
            requestedToUsername: requestedToUsername,
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

  Future<ResponseStatus> userAcceptFriendRequest({
    required String requestedByUsername,
    required String requestedToUsername,
  }) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userAcceptFriendRequest()),
          variables: UserQueries.userAcceptFriendRequestVariables(
            requestedByUsername: requestedByUsername,
            requestedToUsername: requestedToUsername,
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

  Future<ResponseStatus> userRemoveFriendRelation({
    required String requestedByUsername,
    required String requestedToUsername,
  }) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userRemoveFriendRelation()),
          variables: UserQueries.userRemoveFriendRelationVariables(
            requestedByUsername: requestedByUsername,
            requestedToUsername: requestedToUsername,
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

  Future<ResponseStatus> userCreatePost(
    String postId, {
    required String caption,
    required List<String> content,
    required String username,
  }) async {
    try {
      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.userCreatePost()),
          variables: UserQueries.userCreatePostVariables(
            postId,
            username: username,
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

  Future<ResponseStatus> userLikePostAction(
    String postId, {
    bool addLike = true,
    required String username,
  }) async {
    try {
      Future<QueryResult<Object?>> futureMutation;

      if (addLike) {
        futureMutation = _client.mutate(
          MutationOptions(
            document: gql(UserQueries.userAddLikePost()),
            variables: UserQueries.userAddLikePostVariables(
              postId,
              username: username,
            ),
          ),
        );
      } else {
        futureMutation = _client.mutate(
          MutationOptions(
            document: gql(UserQueries.userRemoveLikePost()),
            variables: UserQueries.userRemoveLikePostVariables(
              postId,
              username: username,
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

  Future<SearchResponse> searchUserByUsernameOrName(
    String query, {
    required String username,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.searchUserByUsernameOrName()),
          variables: UserQueries.searchUserByUsernameOrNameVariables(
            query,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const SearchResponse(
          status: ResponseStatus.success,
        );
      }

      List<Future<FriendUserModel>> futureFriendsModel =
          (res).map((user) async {
        FriendUserModel friend =
            await FriendUserModel.createModel(userMap: user);
        return friend;
      }).toList();

      List<FriendUserModel> friends = await Future.wait(futureFriendsModel);

      return SearchResponse(
        status: ResponseStatus.success,
        users: friends,
      );
    } catch (e) {
      safePrint(e.toString());
      return const SearchResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<SearchResponse> searchUserFriendsByUsernameOrName(
    String username, {
    required String currentUsername,
    required String query,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.networkOnly,
          document: gql(UserQueries.searchUserFriendsByUsernameOrName()),
          variables: UserQueries.searchUserFriendsByUsernameOrNameVariables(
            username,
            currentUsername: currentUsername,
            query: query,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const SearchResponse(
          status: ResponseStatus.success,
        );
      }

      var friends = res[0]["friendsConnection"]["edges"] as List;

      List<Future<FriendUserModel>> futureFriendsModel =
          (friends).map((user) async {
        FriendUserModel friend =
            await FriendUserModel.createModel(userMap: user["node"]);
        return friend;
      }).toList();

      List<FriendUserModel> users = await Future.wait(futureFriendsModel);

      return SearchResponse(
        status: ResponseStatus.success,
        users: users,
      );
    } catch (e) {
      safePrint(e.toString());
      return const SearchResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<CommentUserSearchResponse> searchUserFriendsByUsername(
    String username, {
    required String query,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.searchUserFriendsByUsername()),
          variables: UserQueries.searchUserFriendsByUsernameVariables(
            username,
            query: query,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["users"];

      if (res == null || res.isEmpty) {
        return const CommentUserSearchResponse(
          status: ResponseStatus.success,
        );
      }

      var friends = res[0]["friendsConnection"]["edges"] as List;

      List<Future<UserModel>> futureFriendsModel = (friends).map((user) async {
        UserModel friend = await UserModel.createModel(map: user["node"]);
        return friend;
      }).toList();

      List<UserModel> users = await Future.wait(futureFriendsModel);

      return CommentUserSearchResponse(
        status: ResponseStatus.success,
        users: users,
      );
    } catch (e) {
      safePrint(e.toString());
      return const CommentUserSearchResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<IndividualPostResponse> getPostsById(
    String postId, {
    required String username,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getPostById()),
          variables: UserQueries.getPostByIdVariables(
            postId,
            username: username,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["posts"];

      if (res == null || res.isEmpty) {
        return const IndividualPostResponse(
          status: ResponseStatus.success,
        );
      }

      PostModel info = await PostModel.createModel(
        map: res[0],
      );
      CommentInfo commentInfo =
          await CommentInfo.createModel(map: res[0]["commentsConnection"]);

      return IndividualPostResponse(
        status: ResponseStatus.success,
        postInfo: info,
        commentInfo: commentInfo,
      );
    } catch (e) {
      safePrint(e.toString());
      return const IndividualPostResponse(
        status: ResponseStatus.error,
      );
    }
  }

  // todo update return type same as get comments
  Future<CommentModel?> addComment(CommentInputModel commentInput) async {
    try {
      if (commentInput.content.isEmpty && commentInput.media.isEmpty) {
        throw Exception("no data to create comment");
      }

      QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(UserQueries.addComment()),
          variables: UserQueries.addCommentVariables(commentInput),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? comment = result.data?["createComments"]["comments"];

      if (comment == null || comment.isEmpty) return null;

      return await CommentModel.createModel(
        map: comment[0],
      );
    } catch (e) {
      safePrint(e.toString());
      return null;
    }
  }

  Future<CommentResponse> getComments(
    String nodeId, {
    String? cursor,
    bool post = true,
    required String username,
  }) async {
    try {
      QueryResult result = await _client.query(
        QueryOptions(
          document: gql(UserQueries.getComments(
            post,
            cursor: cursor,
          )),
          variables: UserQueries.getCommentsVariable(
            nodeId,
            username: username,
            cursor: cursor,
            post: post,
          ),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      Map? res = result.data;

      if (res == null || res.isEmpty) {
        return const CommentResponse(
          status: ResponseStatus.success,
        );
      }

      CommentInfo commentInfo =
          await CommentInfo.createModel(map: res["commentsConnection"]);

      return CommentResponse(
        status: ResponseStatus.success,
        commentInfo: commentInfo,
      );
    } catch (e) {
      safePrint(e.toString());
      return const CommentResponse(
        status: ResponseStatus.error,
      );
    }
  }
}
