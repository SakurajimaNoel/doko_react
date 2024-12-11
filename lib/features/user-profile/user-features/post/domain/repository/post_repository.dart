import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

abstract class PostRepository {
  Future<bool> getPostWithComment(GetPostInput details);

  Future<bool> getPostComments(GetCommentsInput details);

  Future<bool> getCommentReplies(GetCommentsInput details);

  Future<List<String>> searchUserByUsername(UserSearchInput searchDetails);
}
