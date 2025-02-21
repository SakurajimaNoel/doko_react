import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/repository/node_create_repository.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/poll_create_input.dart';

class PollCreateUseCase extends UseCases<String, PollCreateInput> {
  PollCreateUseCase({
    required this.nodeCreateRepository,
  });

  final NodeCreateRepository nodeCreateRepository;

  @override
  FutureOr<String> call(PollCreateInput params) async {
    return nodeCreateRepository.createNewPoll(params);
  }
}
