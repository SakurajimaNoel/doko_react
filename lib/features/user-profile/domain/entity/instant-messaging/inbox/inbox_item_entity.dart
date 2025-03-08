import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

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
}
