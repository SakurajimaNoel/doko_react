import 'package:doko_react/core/global/auth/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql/client.dart';

part "graphql_client.dart";

class GraphqlConfig {
  static final _apiHttpLink = HttpLink(dotenv.env["GRAPHQL_ENDPOINT"]!);
  static final _messageArchiveHttpLink =
      HttpLink(dotenv.env["MESSAGE_ARCHIVE_ENDPOINT"]!);

  static final _authLink = AuthLink(getToken: () async {
    final tokenEntity = await getUserToken();
    String token = tokenEntity.accessToken;
    return "Bearer $token";
  });

  static GraphQLClient? _graphApiClient;
  static GraphQLClient? _messageArchiveApiClient;

  /// used with normal graph api
  static GraphApiClient getApiGraphQLClient() {
    if (_graphApiClient == null) {
      Link link = _authLink.concat(_apiHttpLink);

      _graphApiClient = GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
        queryRequestTimeout: const Duration(
          seconds: 30,
        ),
      );
    }

    return GraphApiClient(
      client: _graphApiClient!,
    );
  }

  /// used with message archive
  static MessageArchiveApiClient getMessageArchiveGraphQLClient() {
    if (_messageArchiveApiClient == null) {
      Link link = _authLink.concat(_messageArchiveHttpLink);

      _messageArchiveApiClient = GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
        queryRequestTimeout: const Duration(
          seconds: 30,
        ),
      );
    }

    return MessageArchiveApiClient(
      client: _messageArchiveApiClient!,
    );
  }
}
