import 'package:doko_react/secret/secrets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

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
  static Box? _userBox;

  static Future<void> clearCache() async {
    if (_client != null) {
      _client = null;

      if (_userBox != null && _userBox!.isOpen) {
        await _userBox!.clear();
        await _userBox!.close();
        // await Hive.deleteBoxFromDisk(_userBox!.name);
        _userBox = null;
      }
    }
  }

  Future<GraphQLClient> clientToQuery() async {
    if (_client == null) {
      Link link = _authLink.concat(_httpLink);
      var userStatus = await AuthenticationActions.getUserId();
      String userId = "";

      if (userStatus.status == AuthStatus.done) {
        userId = userStatus.message!;
      }

      final boxName = "graphql_cache_$userId";
      final userBox = await Hive.openBox<Map<dynamic, dynamic>?>(boxName);
      _userBox = userBox;
      final store = HiveStore(userBox);

      _client = GraphQLClient(
        link: link,
        cache: GraphQLCache(store: store),
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
