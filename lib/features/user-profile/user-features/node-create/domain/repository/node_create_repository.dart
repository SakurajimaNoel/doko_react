import 'package:doko_react/features/user-profile/user-features/node-create/input/comment_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';

abstract class NodeCreateRepository {
  Future<String> createNewPost(PostCreateInput postDetails);

  Future<String> createNewComment(CommentCreateInput commentDetails);
}
