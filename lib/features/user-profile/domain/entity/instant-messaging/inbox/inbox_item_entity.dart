import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

class InboxItemEntity implements GraphEntity {
  InboxItemEntity({
    required this.user,
    this.lastActivityTime,
    this.displayText,
    required this.unread,
  });

  final String user;
  DateTime? lastActivityTime;
  String? displayText;
  bool unread;

  void updateDisplayText(String? text, DateTime? activityTime) {
    displayText = text;
    lastActivityTime = activityTime;
  }

  void updateUnread(bool newUnread) {
    unread = newUnread;
  }

  static InboxItemEntity createEntity(Map<String, dynamic> map) {
    return InboxItemEntity(
      user: map["inboxUser"],
      unread: map["unread"],
      displayText: map["displayText"],
      lastActivityTime: DateTime.parse(map["createdAt"]).toLocal(),
    );
  }

  @override
  String getNodeKey() {
    return generateInboxItemKey(user);
  }
}
