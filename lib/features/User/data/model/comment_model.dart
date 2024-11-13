// used for comment input

import 'package:doko_react/features/User/data/model/model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';

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

class CommentInfo {
  final NodeInfo info;
  List<CommentModel> comments;

  CommentInfo({
    required this.info,
    required this.comments,
  });

  void addComments(List<CommentModel> newComments) {
    comments.addAll(newComments);
  }

  static Future<CommentInfo> createModel({required Map map}) async {
    var commentFutures = (map["edges"] as List)
        .map((comment) => CommentModel.createModel(map: comment["node"]))
        .toList();

    List<CommentModel> comments = await Future.wait(commentFutures);

    return CommentInfo(
      comments: comments,
      info: NodeInfo.createModel(
        map: map["pageInfo"],
      ),
    );
  }
}

class CommentModel {
  final String id;
  final DateTime createdOn;
  final UserModel commentBy;
  final String media;
  final String signedMedia;
  final List<String> content;
  final List<String> mentions; // used for editing comment
  int likes;
  bool userLike;
  int comments;

  CommentModel({
    required this.id,
    required this.createdOn,
    required this.commentBy,
    required this.media,
    required this.signedMedia,
    required this.content,
    required this.mentions,
    required this.likes,
    required this.userLike,
    required this.comments,
  });

  void updateUserLike(bool like) {
    userLike = like;

    if (like) {
      likes++;
    } else {
      likes--;
    }
  }

  static Future<CommentModel> createModel({required Map map}) async {
    UserModel commentBy = await UserModel.createModel(map: map["commentBy"]);
    bool userLike = (map["likedBy"] as List).length == 1;
    String signedMedia = await StorageUtils.generatePreSignedURL(map["media"]);

    List mapMentions = [];
    if (map["mentions"] != null) {
      mapMentions = map["mentions"] as List;
    }
    List<String> mentions =
        mapMentions.map((element) => element.toString()).toList();

    List mapContent = [];
    if (map["content"] != null) {
      mapContent = map["content"] as List;
    }
    List<String> content =
        mapContent.map((element) => element.toString()).toList();

    return CommentModel(
      id: map["id"],
      createdOn: DateTime.parse(map["createdOn"]),
      commentBy: commentBy,
      media: map["media"],
      signedMedia: signedMedia,
      content: content,
      mentions: mentions,
      likes: map["likedByConnection"]["totalCount"],
      userLike: userLike,
      comments: map["commentsConnection"]["totalCount"],
    );
  }
}
