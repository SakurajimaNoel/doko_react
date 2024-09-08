import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/configs/graphql/graphql_config.dart';
import '../../../../core/helpers/enum.dart';
import '../model/post_model.dart';

class PostResponse {
  final ResponseStatus status;
  final List<ProfilePostModel> posts;

  const PostResponse({
    required this.status,
    this.posts = const [],
  });
}

class PostGraphqlService {
  static GraphqlConfig config = GraphqlConfig();
  GraphQLClient client = config.clientToQuery();

  Future<PostResponse> getPostsByUserId(String id, DateTime cursor) async {
    try {
      QueryResult result = await client.query(
        QueryOptions(
          fetchPolicy: FetchPolicy.cacheAndNetwork,
          document: gql("""
         query Posts(\$options: PostOptions, \$where: PostWhere) {
          posts(options: \$options, where: \$where) {
            id
            caption
            content
            createdOn
          }
        }
        """),
          variables: {
            "options": const {
              "limit": 3,
              "sort": [
                {"createdOn": "DESC"}
              ]
            },
            "where": {
              "createdBy": {
                "id": id,
              },
              "createdOn_LT": cursor.toString(),
            }
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception);
      }

      List? res = result.data?["posts"];

      if (res == null || res.isEmpty) {
        return const PostResponse(
          status: ResponseStatus.success,
        );
      }

      List<ProfilePostModel> posts = res
          .map((postMap) => ProfilePostModel.createModel(
                map: postMap,
              ))
          .toList();

      return PostResponse(
        status: ResponseStatus.success,
        posts: posts,
      );
    } catch (e) {
      safePrint(e.toString());
      return const PostResponse(
        status: ResponseStatus.error,
      );
    }
  }
}
