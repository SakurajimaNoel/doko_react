class InboxMutationInput {
  const InboxMutationInput({
    required this.user,
    required this.inboxUser,
    required this.displayText,
    required this.unread,
  });

  final String user;
  final String inboxUser;
  final String displayText;
  final bool unread;
}
