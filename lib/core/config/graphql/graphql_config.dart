import 'package:doko_react/archive/secret/secrets.dart';
import 'package:doko_react/core/global/auth/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphqlConfig {
  static final _httpLink = HttpLink(Secrets.endpoint);

  static final _authLink = AuthLink(getToken: () async {
    String token = await getAccessToken();
    return "Bearer $token";
  });

  static GraphQLClient? _client;

  // todo: replace flutter_graphql package with graphql package
  static GraphQLClient getGraphQLClient() {
    if (_client == null) {
      Link link = _authLink.concat(_httpLink);

      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
      );
    }

    return _client!;
  }

  // new client used with provider
  static ValueNotifier<GraphQLClient> client =
      ValueNotifier(getGraphQLClient());
}
