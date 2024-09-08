import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/features/User/data/graphql_queries/user_queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../model/post_model.dart';
import '../model/user_model.dart';

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
  final ProfileFriendInfo? info;

  const FriendResponse({
    required this.status,
    this.info,
  });
}

class PostResponse {
  final ResponseStatus status;
  final ProfilePostInfo? info;

  const PostResponse({
    required this.status,
    this.info,
  });
}

class UserGraphqlService {
  static GraphqlConfig config = GraphqlConfig();
  GraphQLClient client = config.clientToQuery();

  Future<UserResponse> getUser(String id) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
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

      UserModel user = UserModel.createModel(map: res[0]);
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
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
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
      QueryResult result = await client.mutate(
        MutationOptions(
          fetchPolicy: FetchPolicy.noCache,
          document: gql(UserQueries.completeUserProfile()),
          variables: UserQueries.completeUserProfileVariables(userDetails),
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      return const UserResponse(
        status: ResponseStatus.success,
      );
    } catch (e) {
      safePrint(e.toString());
      return const UserResponse(
        status: ResponseStatus.error,
      );
    }
  }

  Future<CompleteUserResponse> getCompleteUser(String id) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          document: gql(UserQueries.getCompleteUser()),
          variables: UserQueries.getCompleteUserVariables(id),
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

      CompleteUserModel user = CompleteUserModel.createModel(map: res[0]);

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

  Future<FriendResponse> getFriendsByUserId(String id, String cursor) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          document: gql(UserQueries.getFriendsByUserId()),
          variables: UserQueries.getFriendsByUserIdVariables(id, cursor),
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

      ProfileFriendInfo info = ProfileFriendInfo.createModel(
        map: res[0]["postsConnection"],
      );

      return FriendResponse(
        status: ResponseStatus.success,
        info: info,
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
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          document: gql(UserQueries.getUserPostsByUserId()),
          variables: UserQueries.getUserPostsByUserIdVariables(id, cursor),
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

      ProfilePostInfo info = ProfilePostInfo.createModel(
        map: res[0]["postsConnection"],
      );

      return PostResponse(
        status: ResponseStatus.success,
        info: info,
      );
    } catch (e) {
      safePrint(e.toString());
      return const PostResponse(
        status: ResponseStatus.error,
      );
    }
  }
}
