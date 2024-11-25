import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/entities/setup_mfa/setup_mfa_entity.dart';
import 'package:doko_react/features/authentication/domain/repositories/authentication_repository.dart';

class SetupMFAUseCase extends UseCases<SetupMFAEntity, String> {
  SetupMFAUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<SetupMFAEntity> call(String params) async {
    return auth.setupMFA(params);
  }
}
