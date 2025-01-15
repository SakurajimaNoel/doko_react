import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/helpers/text-controller/mention_text_controller.dart';
import 'package:doko_react/core/validation/input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/entity/comment/comment_media.dart';

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

enum CommentTarget {
  post,
  comment,
}

class CommentCreateInput extends Input {
  CommentCreateInput({
    required this.content,
    this.media,
    this.bucketPath,
    required this.targetNodeId,
    required this.targetNode,
    required this.username,
  });

  final CommentContentInput content;
  final CommentMedia? media;

  // when uri bucket path = uri
  final String? bucketPath;

  final String targetNodeId;
  final CommentTarget targetNode;
  final String username;

  @override
  String invalidateReason() {
    return validate() ? "" : "Can't add empty comment.";
  }

  @override
  bool validate() {
    if (media != null) {
      return bucketPath == null ? false : bucketPath!.isNotEmpty;
    }

    return content.content.isNotEmpty;
  }

  List<Map<String, String>> generateMentions() {
    var mentionMap = content.mentions.map((String username) {
      return {
        "username_EQ": username,
      };
    }).toList();

    return mentionMap;
  }
}
