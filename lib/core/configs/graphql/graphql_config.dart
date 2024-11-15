import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/secret/secrets.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphqlConfig {
  static AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  static final _httpLink = HttpLink(Secrets.endpoint);

  static final _authLink = AuthLink(getToken: () async {
    var result = await auth.getAccessToken();
    if (result.status != AuthStatus.done) {
      return "";
    }

    return "Bearer ${result.value}";
  });

  static GraphQLClient? _client;

  static GraphQLClient getGraphQLClient() {
    if (_client == null) {
      Link link = _authLink.concat(_httpLink);

      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
        defaultPolicies: DefaultPolicies(
          query: Policies(
            fetch: FetchPolicy.cacheAndNetwork,
          ),
          mutate: Policies(
            fetch: FetchPolicy.noCache,
          ),
        ),
      );
    }

    return _client!;
  }

  // new client used with provider
  static ValueNotifier<GraphQLClient> client =
      ValueNotifier(getGraphQLClient());
}
