import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';

class PostContent {
  const PostContent({
    required this.type,
    this.file,
    this.originalImage,
    required this.bucketPath,
  })  : assert(
          type == MediaTypeValue.unknown || file != null,
          "File cannot be null for MediaTypeValue: $type.",
        ),
        assert(
          type != MediaTypeValue.image || originalImage != null,
          "Require original image file after cropping",
        );

  final MediaTypeValue type;
  final String? file;
  final String bucketPath;
  final String? originalImage;
}

class PostPublishPageData {
  const PostPublishPageData({
    required this.content,
    required this.postId,
  });

  final List<PostContent> content;
  final String postId;
}

class PostCreateInput {
  const PostCreateInput({
    required this.username,
    required this.caption,
    required this.content,
    required this.postId,
  });

  final String postId;
  final String username;
  final String caption;
  final List<PostContent> content;
}

// comment create input
class CommentCreateInput {
  // if no media empty string
  final String media;

  // if no mentions empty list;
  final List<String> mentions;

  final List<String> content;

  // username
  final String commentBy;

  // post or comment id
  final String commentOn;

  // comment on post or reply to comment
  final bool isReply;

  const CommentCreateInput({
    required this.media,
    required this.mentions,
    required this.content,
    required this.commentBy,
    required this.commentOn,
    required this.isReply,
  });

  List<Map<String, String>> generateMentions() {
    var mentionMap = mentions.map((String username) {
      return {
        "username": username,
      };
    }).toList();
    return mentionMap;
  }
}
