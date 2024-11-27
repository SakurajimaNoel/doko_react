import 'package:doko_react/features/user-profile/user-features/profile/data/data-sources/profile_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart';

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
}
