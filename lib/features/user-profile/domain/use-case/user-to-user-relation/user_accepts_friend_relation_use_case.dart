import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';

class UserAcceptFriendRelationUseCase
    implements UseCases<bool, UserToUserRelationDetails> {
  UserAcceptFriendRelationUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(UserToUserRelationDetails params) {
    return profileRepository.userAcceptFriendRelation(params);
  }
}
