import 'package:doko_react/features/user-profile/data/data-sources/user_profile_remote_data_source.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';

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

  @override
  Future<bool> userAcceptFriendRelation(
      UserToUserRelationDetails relationDetails) {
    return _remoteDataSource.userAcceptFriendRelation(relationDetails);
  }

  @override
  Future<bool> userCreateFriendRelation(
      UserToUserRelationDetails relationDetails) {
    return _remoteDataSource.userCreateFriendRelation(relationDetails);
  }

  @override
  Future<bool> userRemoveFriendRelation(
      UserToUserRelationDetails relationDetails) {
    return _remoteDataSource.userRemoveFriendRelation(relationDetails);
  }

  @override
  Future<bool> userAddCommentLike(String commentId, String username) {
    return _remoteDataSource.userAddCommentLike(commentId, username);
  }

  @override
  Future<bool> userRemoveCommentLike(String commentId, String username) {
    return _remoteDataSource.userRemoveCommentLike(commentId, username);
  }
}
