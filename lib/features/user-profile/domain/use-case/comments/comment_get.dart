import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';

class CommentGetUseCase extends UseCases<bool, GetNodeInput> {
  CommentGetUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(GetNodeInput params) async {
    return profileRepository.getCommentById(params.nodeId, params.username);
  }
}
