import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';

class ConfirmResetPasswordUseCase
    extends UseCases<bool, ConfirmResetPasswordInput> {
  ConfirmResetPasswordUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<bool> call(ConfirmResetPasswordInput params) {
    if (!params.validate()) {
      throw ApplicationException(reason: params.invalidateReason());
    }

    return auth.confirmResetPassword(params);
  }
}
