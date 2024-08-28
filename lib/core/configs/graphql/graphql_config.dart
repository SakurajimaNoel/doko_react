
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

  GraphQLClient clientToQuery() {
    if (_client == null) {
      Link link = _authLink.concat(_httpLink);

      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      );
    }
    return _client!;
  }
}
