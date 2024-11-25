import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/repositories/authentication_repository.dart';

class VerifyMFAUseCase extends UseCases<bool, String> {
  VerifyMFAUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<bool> call(String params) {
    return auth.verifyMFASetup(params);
  }
}
