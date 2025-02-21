import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';

class DiscussionPublishPageData {
  const DiscussionPublishPageData({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;
}

class DiscussionCreateInput {
  const DiscussionCreateInput({
    required this.discussionId,
    required this.username,
    required this.title,
    required this.text,
    required this.media,
    required this.usersTagged,
  });

  final String discussionId;
  final String username;
  final String title;
  final String text;
  final List<MediaContent> media;
  final List<String> usersTagged;
}
