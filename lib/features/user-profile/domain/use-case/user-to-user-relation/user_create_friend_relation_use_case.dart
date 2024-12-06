import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';

class UserCreateFriendRelationUseCase
    implements UseCases<bool, UserToUserRelationDetails> {
  UserCreateFriendRelationUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(UserToUserRelationDetails params) {
    return profileRepository.userCreateFriendRelation(params);
  }
}
