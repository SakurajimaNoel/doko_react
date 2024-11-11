// used for comment input
import 'package:amplify_flutter/amplify_flutter.dart';

class CommentInputModel {
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

  const CommentInputModel({
    required this.media,
    required this.mentions,
    required this.content,
    required this.commentBy,
    required this.commentOn,
    this.isReply = false,
  });

  List<Map<String, String>> generateMentions() {
    safePrint("mention trial");
    safePrint(mentions.length);
    var mentionMap = mentions.map((String username) {
      return {
        "username": username,
      };
    }).toList();
    safePrint(mentionMap);
    return mentionMap;
  }
}
