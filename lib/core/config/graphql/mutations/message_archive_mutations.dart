class MessageArchiveMutations {
  /// update unread status
  static String markInboxAsRead() {
    return """
    mutation UpdateMessageInbox(\$input: UpdateMessageInboxInput!) {
      updateMessageInbox(input: \$input) {
        unread
      }
    }
    """;
  }

  static Map<String, dynamic> markInboxAsReadVariables({
    required String inboxUser,
    required String user,
  }) {
    return {
      "input": {
        "user": user,
        "inboxUser": inboxUser,
        "unread": false,
      },
    };
  }
}
