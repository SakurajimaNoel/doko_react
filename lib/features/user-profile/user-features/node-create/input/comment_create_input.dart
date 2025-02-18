import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/text-controller/mention_text_controller.dart';
import 'package:doko_react/core/validation/input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/entity/comment/comment_media.dart';

class CommentCreateInput extends Input {
  CommentCreateInput({
    required this.content,
    this.media,
    this.bucketPath,
    required this.targetNodeId,
    required this.targetNode,
    required this.username,
    this.replyOn,
  });

  final CommentContentInput content;
  final CommentMedia? media;

  // when uri bucket path = uri
  final String? bucketPath;

  // reply on comment id
  final String? replyOn;

  final String targetNodeId;
  final DokiNodeType targetNode;
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
