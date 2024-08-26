import 'package:doko_react/features/authentication/data/auth.dart';
import 'package:doko_react/secret/secrets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphqlConfig {
  static final _httpLink = HttpLink(Secrets.endpoint);

  static final _authLink = AuthLink(getToken: () async {
    var result = await AuthenticationActions.getAccessToken();
    if (result.status != AuthStatus.done) {
      return "";
    }

    return "Bearer ${result.value}";
  });

  GraphQLClient clientToQuery() {
    Link link = _authLink.concat(_httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }
}
