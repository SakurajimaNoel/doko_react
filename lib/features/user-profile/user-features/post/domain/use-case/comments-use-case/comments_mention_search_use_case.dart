import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/repository/post_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class CommentsMentionSearchUseCase
    implements UseCases<List<String>, UserSearchInput> {
  const CommentsMentionSearchUseCase({
    required this.postRepository,
  });

  final PostRepository postRepository;

  @override
  FutureOr<List<String>> call(UserSearchInput params) {
    return postRepository.searchUserByUsername(params);
  }
}
