import 'package:doko_react/features/complete-profile/data/data-sources/complete_profile_remote_data_source.dart';
import 'package:doko_react/features/complete-profile/domain/repositories/complete_profile_repository.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';

class CompleteProfileRepositoryImpl extends CompleteProfileRepository {
  CompleteProfileRepositoryImpl({
    required CompleteProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CompleteProfileRemoteDataSource _remoteDataSource;

  @override
  Future<bool> checkUsernameAvailability(UsernameInput usernameInput) {
    return _remoteDataSource.checkUsernameAvailability(usernameInput);
  }

  @override
  Future<bool> completeUserProfile(
      CompleteProfileInput userDetails, String bucketPath) {
    return _remoteDataSource.completeUserProfile(userDetails, bucketPath);
  }
}
