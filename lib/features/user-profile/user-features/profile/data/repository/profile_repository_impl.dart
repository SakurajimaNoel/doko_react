import 'package:doko_react/features/user-profile/user-features/profile/data/data-sources/profile_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<bool> getCompleteUserProfile(
      String username, String currentUsername) async {
    return _remoteDataSource.getCompleteUserDetails(
      username,
      currentUsername: currentUsername,
    );
  }

  @override
  Future<bool> editUserProfile(
      EditProfileInput editDetails, String bucketPath) async {
    return _remoteDataSource.editUserProfile(editDetails, bucketPath);
  }

  @override
  Future<bool> getUserPosts(UserProfileNodesInput postDetails) async {
    return _remoteDataSource.getUserProfilePosts(postDetails);
  }

  @override
  Future<bool> getUserDiscussions(
      UserProfileNodesInput discussionDetails) async {
    return _remoteDataSource.getUserProfileDiscussions(discussionDetails);
  }

  @override
  Future<bool> getUserPolls(UserProfileNodesInput pollDetails) async {
    return _remoteDataSource.getUserProfilePolls(pollDetails);
  }

  @override
  Future<bool> getUserFriends(UserProfileNodesInput friendsDetails) {
    return _remoteDataSource.getUserProfileFriends(friendsDetails);
  }

  @override
  Future<List<String>> searchUserByUsernameOrName(
      UserSearchInput searchDetails) {
    return _remoteDataSource.searchUserByNameOrUsername(searchDetails);
  }

  @override
  Future<List<String>> searchUserFriendsByUsernameOrName(
      UserFriendsSearchInput searchDetails) {
    return _remoteDataSource.searchUserFriendsByNameOrUsername(searchDetails);
  }

  @override
  Future<bool> getUserPendingIncomingRequests(UserProfileNodesInput details) {
    return _remoteDataSource.getUserPendingIncomingFriendRequests(details);
  }

  @override
  Future<bool> getUserPendingOutgoingRequests(UserProfileNodesInput details) {
    return _remoteDataSource.getUserPendingOutgoingFriendRequests(details);
  }

  @override
  Future<List<String>> searchUserByUsername(UserSearchInput searchDetails) {
    return _remoteDataSource.searchUserByUsername(searchDetails);
  }

  @override
  Future<bool> getUserTimeline(UserProfileNodesInput details) {
    return _remoteDataSource.getUserTimeline(details);
  }
}
