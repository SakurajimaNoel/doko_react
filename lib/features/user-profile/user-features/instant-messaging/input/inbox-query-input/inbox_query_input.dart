class InboxQueryInput {
  const InboxQueryInput({
    required this.cursor,
    required this.username,
  });

  final String cursor;
  final String username;
}
