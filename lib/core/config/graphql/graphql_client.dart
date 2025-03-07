part of "graphql_config.dart";

abstract class ApiClient {
  GraphQLClient get client;
}

class GraphApiClient implements ApiClient {
  const GraphApiClient({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  @override
  GraphQLClient get client => _client;
}

class MessageArchiveApiClient implements ApiClient {
  const MessageArchiveApiClient({
    required GraphQLClient client,
  }) : _client = client;

  final GraphQLClient _client;

  @override
  GraphQLClient get client => _client;
}
