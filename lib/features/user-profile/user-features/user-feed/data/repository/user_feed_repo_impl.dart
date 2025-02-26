import 'package:doko_react/features/user-profile/user-features/user-feed/data/data-sources/user_feed_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/domain/repository/user_feed_repo.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/input/user_feed_input.dart';

class UserFeedRepoImpl implements UserFeedRepo {
  const UserFeedRepoImpl({required remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final UserFeedRemoteDataSource _remoteDataSource;

  @override
  Future<bool> getUserFeed(UserFeedInput details) async {
    return _remoteDataSource.fetchUserFeed(details);
  }
}
