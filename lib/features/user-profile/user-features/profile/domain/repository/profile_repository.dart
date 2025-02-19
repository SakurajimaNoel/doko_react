import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

abstract class ProfileRepository {
  Future<bool> getCompleteUserProfile(String username, String currentUsername);

  Future<bool> editUserProfile(EditProfileInput editDetails, String bucketPath);

  Future<bool> getUserPosts(UserProfileNodesInput postDetails);

  Future<bool> getUserDiscussions(UserProfileNodesInput discussionDetails);

  Future<bool> getUserFriends(UserProfileNodesInput friendsDetails);

  Future<List<String>> searchUserByUsernameOrName(
      UserSearchInput searchDetails);

  Future<List<String>> searchUserFriendsByUsernameOrName(
      UserFriendsSearchInput searchDetails);

  Future<bool> getUserPendingOutgoingRequests(UserProfileNodesInput details);

  Future<bool> getUserPendingIncomingRequests(UserProfileNodesInput details);

  Future<List<String>> searchUserByUsername(UserSearchInput searchDetails);
}
