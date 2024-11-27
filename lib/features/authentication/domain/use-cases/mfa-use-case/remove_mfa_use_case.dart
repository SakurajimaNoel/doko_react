import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/repository/authentication_repository.dart';

class RemoveMFAUseCase extends UseCases<void, NoParams> {
  RemoveMFAUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<void> call(NoParams params) {
    return auth.removeMFA();
  }
}
