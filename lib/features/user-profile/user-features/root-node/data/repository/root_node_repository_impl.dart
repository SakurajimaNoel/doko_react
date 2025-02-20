import 'package:doko_react/features/user-profile/user-features/root-node/data/data-source/post_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/repository/root_node_repository.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';

class RootNodeRepositoryImpl implements RootNodeRepository {
  const RootNodeRepositoryImpl({required this.remoteDataSource});

  final PostRemoteDataSource remoteDataSource;

  @override
  Future<bool> getPrimaryNodeComments(GetCommentsInput details) {
    return remoteDataSource.getPrimaryNodeComments(details);
  }

  @override
  Future<bool> getPostWithComment(GetNodeInput details) {
    return remoteDataSource.getPostWithComments(details);
  }

  @override
  Future<bool> getCommentWithReplies(GetNodeInput details) {
    return remoteDataSource.getCommentWithReplies(details);
  }

  @override
  Future<bool> getDiscussionWithComment(GetNodeInput details) {
    return remoteDataSource.getDiscussionWithComments(details);
  }

  @override
  Future<bool> getPollWithComment(GetNodeInput details) {
    return remoteDataSource.getPollWithComments(details);
  }
}
