import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';

class PostRemoveLikeUseCase extends UseCases<bool, UserPostLikeActionInput> {
  PostRemoveLikeUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(UserPostLikeActionInput params) async {
    return profileRepository.userRemovePostLike(params.postId, params.username);
  }
}
