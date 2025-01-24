import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';

class PostGetUseCase extends UseCases<bool, GetPostInput> {
  PostGetUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(GetPostInput params) async {
    return profileRepository.getPostById(params.postId, params.username);
  }
}
