import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-mutation-input/inbox_mutation_input.dart';

class MessageArchiveMutations {
  static String updateUserInbox() {
    return """
    mutation BatchCreateMessageInbox(\$input: [CreateMessageInboxInput!]!) {
      batchCreateMessageInbox(input: \$input) {
        user
        inboxUser
        unread
      }
    }
    """;
  }

  static Map<String, dynamic> updateUserInboxVariables({
    required List<InboxMutationInput> inboxDetails,
  }) {
    return {
      "input": _createInboxInput(inboxDetails),
    };
  }

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

  /// delete inbox entry
  static String deleteInboxEntry() {
    return """
    mutation DeleteMessageInbox(\$input: DeleteMessageInboxInput!) {
      deleteMessageInbox(input:\$input) {
        user
      }
    }
    """;
  }

  static Map<String, dynamic> deleteInboxEntryVariables({
    required String user,
    required String inboxUser,
  }) {
    return {
      "input": {
        "inboxUser": inboxUser,
        "user": user,
      }
    };
  }

  /// add messages to archive
  static String addMessageToArchive() {
    return """
    mutation CreateMessageArchive(\$input: [CreateMessageArchiveInput!]!) {
      batchCreateMessageArchive(input: \$input) {
        id
      }
    }
    """;
  }

  static Map<String, dynamic> addMessageToArchiveVariables({
    required List<ChatMessage> messages,
  }) {
    return {
      "input": _createMessageInput(messages),
    };
  }

  // edit message
  static String editMessageInArchive() {
    return """
    mutation UpdateMessageArchive(\$input: UpdateMessageArchiveInput!) {
      updateMessageArchive(input: \$input) {
        id
        body
        edited
      }
    }
    """;
  }

  static Map<String, dynamic> editMessageInArchiveVariables(
      EditMessage message) {
    return {
      "input": {
        "archive": createMessageArchiveKey(message.from, message.to),
        "id": message.id,
        "body": message.body,
        "edited": true,
      }
    };
  }

  // edit message
  static String deleteMessageInArchive() {
    return """
    mutation UpdateMessageArchive(\$input: UpdateMessageArchiveInput!) {
      updateMessageArchive(input: \$input) {
        id
        deleted
      }
    }
    """;
  }

  static Map<String, dynamic> deleteMessageInArchiveVariables(
      DeleteMessage message) {
    return {
      "input": {
        "archive": createMessageArchiveKey(message.from, message.to),
        "id": message.id.first,
        "deleted": true,
      }
    };
  }
}

List<Map<String, dynamic>> _createMessageInput(List<ChatMessage> messages) {
  List<Map<String, dynamic>> messageInput = [];
  for (var message in messages) {
    messageInput.add({
      "id": message.id,
      "from": message.from,
      "to": message.to,
      "subject": message.subject.value,
      "body": message.body,
      "edited": false,
      "deleted": false,
      "forwarded": message.forwarded,
      "archive": createMessageArchiveKey(message.from, message.to),
      "replyFor": message.replyOn,
    });
  }

  return messageInput;
}

List<Map<String, dynamic>> _createInboxInput(List<InboxMutationInput> inbox) {
  List<Map<String, dynamic>> inboxInput = [];
  for (var detail in inbox) {
    inboxInput.add({
      "displayText": detail.displayText,
      "inboxUser": detail.inboxUser,
      "unread": detail.unread,
      "user": detail.user,
    });
  }

  return inboxInput;
}
