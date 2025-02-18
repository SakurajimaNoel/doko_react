import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';

class PostPublishPageData {
  const PostPublishPageData({
    required this.content,
    required this.postId,
  });

  final List<MediaContent> content;
  final String postId;
}

class PostCreateInput {
  const PostCreateInput({
    required this.username,
    required this.caption,
    required this.content,
    required this.postId,
    required this.usersTagged,
  });

  final String postId;
  final String username;
  final String caption;
  final List<MediaContent> content;
  final List<String> usersTagged;

  List<Map<String, String>> generateUserTagged() {
    var usersTaggedMap = usersTagged.map((String username) {
      return {
        "username_EQ": username,
      };
    }).toList();

    return usersTaggedMap;
  }

  PostCreateInput copyWith({
    String? postId,
    String? username,
    String? caption,
    List<MediaContent>? content,
    List<String>? usersTagged,
  }) {
    return PostCreateInput(
      username: username ?? this.username,
      caption: caption ?? this.caption,
      content: content ?? this.content,
      postId: postId ?? this.postId,
      usersTagged: usersTagged ?? this.usersTagged,
    );
  }
}
