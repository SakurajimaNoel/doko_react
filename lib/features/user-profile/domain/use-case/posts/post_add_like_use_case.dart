import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';

class PostAddLikeUseCase extends UseCases<bool, UserNodeLikeActionInput> {
  PostAddLikeUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(UserNodeLikeActionInput params) async {
    return profileRepository.userAddPostLike(params.nodeId, params.username);
  }
}
