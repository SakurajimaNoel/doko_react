import 'dart:collection';

import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

const _messageLimit = 5;

class InboxItemEntity extends GraphEntity {
  InboxItemEntity({
    required this.messages,
  });

  /// latest messages are at the front
  /// max length of messages is 5
  /// message keys are stored
  Queue<String> messages;

  void addNewMessage(String messageKey) {
    messages.addFirst(messageKey);

    if (messages.length > _messageLimit) {
      messages.removeLast();
    }
  }
}
