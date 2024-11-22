import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/entities/login/login_entity.dart';
import 'package:doko_react/features/authentication/domain/repositories/authentication_repository.dart';

class ConfirmLoginUseCase extends UseCases<LoginStatus, String> {
  ConfirmLoginUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<LoginStatus> call(String params) {
    if (params.isEmpty || params.length != 6) {
      throw const ApplicationException(
          reason: "Invalid code. Please try again.");
    }

    return auth.confirmLogin(params);
  }
}
