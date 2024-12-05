import 'package:doko_react/features/user-profile/data/data-sources/user_profile_remote_data_source.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  const UserProfileRepositoryImpl({required remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final UserProfileRemoteDataSource _remoteDataSource;

  @override
  Future<bool> userAddPostLike(String postId, String username) async {
    return _remoteDataSource.userAddPostLike(postId, username);
  }

  @override
  Future<bool> userRemovePostLike(String postId, String username) async {
    return _remoteDataSource.userRemovePostLike(postId, username);
  }
}
