import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class UserGetUseCase extends UseCases<bool, GetProfileInput> {
  UserGetUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(GetProfileInput params) async {
    return profileRepository.getUserByUsername(
        params.username, params.currentUsername);
  }
}
