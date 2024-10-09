import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/secret/secrets.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

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
  static Box? _userBox;

  static Future<void> initGraphQLClient() async {
    Link link = _authLink.concat(_httpLink);
    var userStatus = await auth.getUserId();
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

    safePrint("graphql client initialized");
  }

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

  static GraphQLClient getGraphQLClient() {
    if (_client == null) {
      throw ("GraphQL client is not initialized. Ensure you call initGraphQLClient after authentication.");
    }

    return _client!;
  }
}
