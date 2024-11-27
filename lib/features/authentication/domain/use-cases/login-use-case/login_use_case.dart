import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/entities/login/login_entity.dart';
import 'package:doko_react/features/authentication/domain/repository/authentication_repository.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';

class LoginUseCase extends UseCases<LoginStatus, LoginInput> {
  LoginUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<LoginStatus> call(LoginInput params) {
    if (!params.validate()) {
      throw ApplicationException(reason: params.invalidateReason());
    }

    return auth.login(params);
  }
}
