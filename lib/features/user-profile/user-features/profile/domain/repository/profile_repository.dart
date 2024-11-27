abstract class ProfileRepository {
  Future<bool> getCompleteUserProfile(String username, String currentUsername);
}
