import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/repository/authentication_repository.dart';

class LogoutUseCase extends UseCases<void, NoParams> {
  LogoutUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<void> call(NoParams params) async {
    await auth.logOut();
  }
}
