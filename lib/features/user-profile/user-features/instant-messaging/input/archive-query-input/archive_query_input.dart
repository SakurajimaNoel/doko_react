import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class ArchiveQueryInput {
  const ArchiveQueryInput({
    required this.username,
    required this.cursor,
    required this.currentUser,
  });

  final String username;
  final String cursor;
  final String currentUser;

  String getArchive() {
    return createMessageArchiveKey(username, currentUser);
  }
}
