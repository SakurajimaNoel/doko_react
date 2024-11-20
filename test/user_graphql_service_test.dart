import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/features/User/data/graphql_queries/user_queries.dart';
import 'package:doko_react/archive/features/User/data/model/user_model.dart';
import 'package:doko_react/archive/features/User/data/services/user_graphql_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockGraphQLClient extends Mock implements GraphQLClient {}

class MockBaseOptions extends Mock implements QueryOptions {}

class FakeQueryOptions extends Fake implements QueryOptions {}

class UserMatcher extends Matcher {
  final String expectedId;
  final String expectedName;
  final String expectedUsername;
  final String expectedProfilePicture;
  final String expectedSignedProfilePicture;

  UserMatcher({
    required this.expectedId,
    required this.expectedName,
    required this.expectedUsername,
    required this.expectedProfilePicture,
    required this.expectedSignedProfilePicture,
  });

  @override
  Description describe(Description description) {
    return description.add("check for user");
  }

  @override
  bool matches(item, Map matchState) {
    if (item is UserModel) {
      return item.id == expectedId &&
          item.name == expectedName &&
          item.username == expectedUsername &&
          item.profilePicture == expectedProfilePicture &&
          item.signedProfilePicture == expectedSignedProfilePicture;
    }
    return false;
  }
}

void main() {
  late MockGraphQLClient client;
  late UserGraphqlService userGraphqlService;

  String id = "abc";
  String name = "name";
  String username = "username";
  String profilePicture = "profile-picture";

  setUp(() {
    client = MockGraphQLClient();
    userGraphqlService = UserGraphqlService(client: client);

    registerFallbackValue(FakeQueryOptions());
  });

  group("user graphql api test - ", () {
    group("get user method - ", () {
      test("given user id return user with id", () async {
        when(() => client.query(any())).thenAnswer((_) async {
          return QueryResult(
              options: QueryOptions(document: gql(UserQueries.getUser())),
              source: QueryResultSource.network,
              data: {
                "users": [
                  {
                    "id": id,
                    "name": name,
                    "username": username,
                    "profilePicture": profilePicture,
                  }
                ],
              });
        });

        final result = await userGraphqlService.getUser(id);

        expect(result.status, ResponseStatus.success);
        expect(
          result.user,
          UserModel(
            name: name,
            username: username,
            profilePicture: profilePicture,
            id: id,
            signedProfilePicture: "signedProfilePicture",
          ),
        );
      });
    });
  });
}
