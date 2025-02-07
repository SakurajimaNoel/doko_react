import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';

abstract class RootNodeRepository {
  Future<bool> getPostWithComment(GetNodeInput details);

  Future<bool> getPostComments(GetCommentsInput details);

  Future<bool> getCommentReplies(GetCommentsInput details);
}
