import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class ProfileUseCase extends UseCases<bool, GetProfileInput> {
  ProfileUseCase({required profileRepository})
      : _profileRepository = profileRepository;
  final ProfileRepository _profileRepository;

  @override
  FutureOr<bool> call(GetProfileInput params) async {
    return _profileRepository.getCompleteUserProfile(
        params.username, params.currentUsername);
  }
}
