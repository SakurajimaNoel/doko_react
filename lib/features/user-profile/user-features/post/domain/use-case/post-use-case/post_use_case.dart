import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/repository/post_repository.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';

class PostUseCase implements UseCases<bool, GetPostInput> {
  const PostUseCase({
    required this.postRepository,
  });

  final PostRepository postRepository;

  @override
  FutureOr<bool> call(GetPostInput params) {
    return postRepository.getPostWithComment(params);
  }
}
