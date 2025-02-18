import 'package:doko_react/features/user-profile/user-features/node-create/data/data-source/node_create_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/repository/node_create_repository.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/comment_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';

class NodeCreateRepositoryImpl implements NodeCreateRepository {
  const NodeCreateRepositoryImpl({
    required remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NodeCreateRemoteDataSource _remoteDataSource;

  @override
  Future<String> createNewPost(PostCreateInput postDetails) {
    return _remoteDataSource.createNewPost(postDetails);
  }

  @override
  Future<String> createNewComment(CommentCreateInput commentDetails) {
    return _remoteDataSource.createComment(commentDetails);
  }
}
