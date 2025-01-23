import 'dart:collection';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

ChatMessage? _getLatestMessage(InboxItemEntity inbox) {
  UserGraph graph = UserGraph();

  for (var messageKey in inbox.messages) {
    if (!graph.containsKey(messageKey)) continue;
    final message = graph.getValueByKey(messageKey)! as MessageEntity;

    return message.message;
  }

  return null;
}

int _compareInboxItems(String userA, String userB) {
  UserGraph graph = UserGraph();

  String a = generateInboxItemKey(userA);
  String b = generateInboxItemKey(userB);

  if (!graph.containsKey(a)) return 1;
  if (!graph.containsKey(b)) return -1;

  // both exists
  final inboxA = graph.getValueByKey(a)! as InboxItemEntity;
  final inboxB = graph.getValueByKey(b)! as InboxItemEntity;

  ChatMessage? latestA = _getLatestMessage(inboxA);
  ChatMessage? latestB = _getLatestMessage(inboxB);

  if (latestA == latestB && latestB == null) return 0;
  if (latestA == null) return -1;
  if (latestB == null) return 1;

  if (latestA.sendAt == latestB.sendAt) return 0;
  return latestA.sendAt.isAfter(latestB.sendAt) ? 1 : -1;
}

class InboxEntity extends GraphEntity {
  InboxEntity({
    required PageInfo pageInfo,
    required List<String> inboxItems,
  })  : _pageInfo = pageInfo,
        _empty = false,
        items = SplayTreeSet<String>(_compareInboxItems)..addAll(inboxItems);

  InboxEntity.empty()
      : _pageInfo = PageInfo.empty(),
        _empty = true,
        items = SplayTreeSet<String>(_compareInboxItems);

  PageInfo _pageInfo;
  SplayTreeSet<String> items;

  bool _empty = true;

  PageInfo get pageInfo => _pageInfo;

  bool get isEmpty => _empty;

  bool get isNotEmpty => !_empty;

  void updatePageInfo(PageInfo pageInfo) {
    _pageInfo = pageInfo;
    _empty = false;
  }

  void addItems(List<String> inboxItems) {
    items.addAll(inboxItems);
  }

  void reorder(String inboxItemKey) {
    items.remove(inboxItemKey);
    items.add(inboxItemKey);
  }
}
