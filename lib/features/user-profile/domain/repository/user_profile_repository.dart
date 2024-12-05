abstract class UserProfileRepository {
  Future<bool> userAddPostLike(String postId, String username);

  Future<bool> userRemovePostLike(String postId, String username);
}
