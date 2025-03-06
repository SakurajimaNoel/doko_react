import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

class InboxItemEntity implements GraphEntity {
  InboxItemEntity({
    required this.user,
    this.lastActivityTime,
    this.displayText,
  });

  final String user;
  DateTime? lastActivityTime;
  String? displayText;

  void updateDisplayText(String? text, DateTime? activityTime) {
    displayText = text;
    lastActivityTime = activityTime;
  }
}
