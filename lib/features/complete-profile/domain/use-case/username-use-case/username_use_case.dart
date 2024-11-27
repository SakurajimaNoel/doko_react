import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/complete-profile/domain/repository/complete_profile_repository.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';

class UsernameUseCase extends UseCases<bool, UsernameInput> {
  UsernameUseCase({required this.completeProfile});

  final CompleteProfileRepository completeProfile;

  @override
  FutureOr<bool> call(UsernameInput params) {
    if (!params.validate()) {
      throw ApplicationException(reason: params.invalidateReason());
    }

    return completeProfile.checkUsernameAvailability(params);
  }
}
