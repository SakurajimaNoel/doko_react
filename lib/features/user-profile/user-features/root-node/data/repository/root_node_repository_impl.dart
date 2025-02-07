import 'package:doko_react/features/user-profile/user-features/root-node/data/data-source/post_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/repository/root_node_repository.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';

class RootNodeRepositoryImpl implements RootNodeRepository {
  const RootNodeRepositoryImpl({required this.remoteDataSource});

  final PostRemoteDataSource remoteDataSource;

  @override
  Future<bool> getCommentReplies(GetCommentsInput details) {
    return remoteDataSource.getCommentReplies(details);
  }

  @override
  Future<bool> getPostComments(GetCommentsInput details) {
    return remoteDataSource.getPostComments(details);
  }

  @override
  Future<bool> getPostWithComment(GetNodeInput details) {
    return remoteDataSource.getPostWithComments(details);
  }
}
