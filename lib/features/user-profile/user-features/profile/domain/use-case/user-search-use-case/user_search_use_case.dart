import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class UserSearchUseCase extends UseCases<List<String>, UserSearchInput> {
  UserSearchUseCase({required this.profileRepository});

  final ProfileRepository profileRepository;

  @override
  FutureOr<List<String>> call(UserSearchInput params) async {
    return profileRepository.searchUserByUsernameOrName(params);
  }
}
