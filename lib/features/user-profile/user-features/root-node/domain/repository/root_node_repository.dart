import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';

abstract class RootNodeRepository {
  Future<bool> getPostWithComment(GetNodeInput details);

  Future<bool> getDiscussionWithComment(GetNodeInput details);

  Future<bool> getPollWithComment(GetNodeInput details);

  Future<bool> getPrimaryNodeComments(GetCommentsInput details);

  Future<bool> getCommentWithReplies(GetNodeInput details);
}
