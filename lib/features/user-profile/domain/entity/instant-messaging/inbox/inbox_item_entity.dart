import 'dart:collection';

import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

const _messageLimit = 5;

enum InboxLastActivity {
  selfDeleteAll,
  selfEdit,
  remoteDeleteAll,
  remoteEdit,
  normalText,
  empty,
}

class LatestActivity {
  LatestActivity({
    required InboxLastActivity activity,
    DateTime? lastActivityTime,
  })  : _activity = activity,
        _lastActivityTime = lastActivityTime ?? DateTime.now();

  LatestActivity.empty()
      : _activity = InboxLastActivity.empty,
        _lastActivityTime = DateTime.now();

  InboxLastActivity _activity;
  DateTime _lastActivityTime;

  InboxLastActivity get activity => _activity;
  DateTime get lastActivityTime => _lastActivityTime;

  void updateLatestActivity({
    required InboxLastActivity activity,
    DateTime? lastActivityTime,
  }) {
    _activity = activity;
    _lastActivityTime = lastActivityTime ?? DateTime.now();
  }

  String? getActivityText(String username) {
    switch (_activity) {
      case InboxLastActivity.selfDeleteAll:
        return "You deleted the message.";
      case InboxLastActivity.selfEdit:
        return "You edited the message.";
      case InboxLastActivity.remoteDeleteAll:
        return "@$username deleted the message.";
      case InboxLastActivity.remoteEdit:
        return "@$username edited the message.";
      default:
        return null;
    }
  }

  String? getActivityTime() {
    if (_activity == InboxLastActivity.empty) return null;

    return formatDateTimeToTimeString(_lastActivityTime);
  }
}

class InboxItemEntity extends GraphEntity {
  InboxItemEntity({
    required this.messages,
    required LatestActivity activity,
  }) : _activity = activity;

  /// latest messages are at the front
  /// max length of messages is 5
  /// message keys are stored
  Queue<String> messages;
  final LatestActivity _activity;

  LatestActivity get activity => _activity;

  void addNewMessage(String messageKey, DateTime sendAt) {
    _activity.updateLatestActivity(
      activity: InboxLastActivity.normalText,
      lastActivityTime: sendAt,
    );
    if (messages.contains(messageKey)) return;

    messages.addFirst(messageKey);

    if (messages.length > _messageLimit) {
      messages.removeLast();
    }
  }
}
