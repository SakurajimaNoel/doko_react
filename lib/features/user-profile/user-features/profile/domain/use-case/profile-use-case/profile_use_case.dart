import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class ProfileUseCase extends UseCases<bool, UserProfileNodesInput> {
  ProfileUseCase({required this.profileRepository});

  final ProfileRepository profileRepository;

  @override
  FutureOr<bool> call(UserProfileNodesInput params) async {
    return profileRepository.getCompleteUserProfile(
        params.username, params.currentUsername);
  }
}
