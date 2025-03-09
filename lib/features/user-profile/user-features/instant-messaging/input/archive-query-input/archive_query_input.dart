class ArchiveQueryInput {
  const ArchiveQueryInput({
    required this.username,
    required this.cursor,
    required this.currentUser,
  });

  final String username;
  final String cursor;
  final String currentUser;
}
