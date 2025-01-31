import 'package:doko_react/core/global/auth/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql/client.dart';

class GraphqlConfig {
  static final _httpLink = HttpLink(dotenv.env["GRAPHQL_ENDPOINT"]!);

  static final _authLink = AuthLink(getToken: () async {
    final tokenEntity = await getUserToken();
    String token = tokenEntity.accessToken;
    return "Bearer $token";
  });

  static GraphQLClient? _client;

  static GraphQLClient getGraphQLClient() {
    if (_client == null) {
      Link link = _authLink.concat(_httpLink);

      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
        queryRequestTimeout: const Duration(
          seconds: 30,
        ),
      );
    }

    return _client!;
  }

  // new client used with provider
  static ValueNotifier<GraphQLClient> client =
      ValueNotifier(getGraphQLClient());
}
