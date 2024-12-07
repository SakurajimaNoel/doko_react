import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class UserFriendsUseCase extends UseCases<bool, UserProfileNodesInput> {
  UserFriendsUseCase({required this.profileRepository});

  final ProfileRepository profileRepository;

  @override
  FutureOr<bool> call(UserProfileNodesInput params) async {
    return profileRepository.getUserFriends(params);
  }
}
