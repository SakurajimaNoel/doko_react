import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/secret/secrets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../data/auth.dart';

class GraphqlConfig {
  static final _httpLink = HttpLink(Secrets.endpoint);

  static final _authLink = AuthLink(getToken: () async {
    var result = await AuthenticationActions.getAccessToken();
    if (result.status != AuthStatus.done) {
      return "";
    }

    return "Bearer ${result.value}";
  });

  static GraphQLClient? _client;

  static void clearCache() {
    if (_client != null) {
      // use when need to refetch queries
      safePrint("cache cleared");
      _client!.resetStore(
        refetchQueries: false,
      );
      _client!.cache.store.reset();
    }
  }

  GraphQLClient clientToQuery() {
    if (_client == null) {
      Link link = _authLink.concat(_httpLink);

      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(),
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
}
