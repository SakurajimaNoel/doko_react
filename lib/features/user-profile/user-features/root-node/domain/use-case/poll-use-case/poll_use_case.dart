import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/repository/root_node_repository.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';

class PollUseCase implements UseCases<bool, GetNodeInput> {
  const PollUseCase({
    required this.rootNodeRepository,
  });

  final RootNodeRepository rootNodeRepository;

  @override
  FutureOr<bool> call(GetNodeInput params) {
    return rootNodeRepository.getPollWithComment(params);
  }
}
