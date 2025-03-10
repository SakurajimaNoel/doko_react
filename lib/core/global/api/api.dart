import 'package:amplify_flutter/amplify_flutter.dart';

Future<GraphQLResponse> mutate(GraphQLRequest request) async {
  return await Amplify.API.mutate(request: request).response;
}
