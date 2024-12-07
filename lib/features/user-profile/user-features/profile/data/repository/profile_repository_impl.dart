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
  Future<bool> loadMoreUserPost(UserProfileNodesInput postDetails) async {
    return _remoteDataSource.loadUserProfilePost(postDetails);
  }

  @override
  Future<bool> getUserFriends(UserProfileNodesInput friendsDetails) {
    return _remoteDataSource.getUserProfileFriends(friendsDetails);
  }
}
