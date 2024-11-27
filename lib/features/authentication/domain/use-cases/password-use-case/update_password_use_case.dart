import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/authentication/domain/repository/authentication_repository.dart';
import 'package:doko_react/features/authentication/input/authentication_input.dart';

class UpdatePasswordUseCase extends UseCases<bool, UpdatePasswordInput> {
  UpdatePasswordUseCase({required this.auth});

  final AuthenticationRepository auth;

  @override
  FutureOr<bool> call(UpdatePasswordInput params) {
    if (!params.validate()) {
      throw ApplicationException(reason: params.invalidateReason());
    }

    return auth.updatePassword(params);
  }
}
