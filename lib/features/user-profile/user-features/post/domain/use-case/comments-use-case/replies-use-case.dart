import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/repository/post_repository.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';

class RepliesUseCase implements UseCases<bool, GetCommentsInput> {
  const RepliesUseCase({
    required this.postRepository,
  });

  final PostRepository postRepository;

  @override
  FutureOr<bool> call(GetCommentsInput params) {
    return postRepository.getCommentReplies(params);
  }
}
