import 'package:doko_react/features/user-profile/user-features/post/data/data-source/post_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/repository/post_repository.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';

class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl({required this.remoteDataSource});

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
