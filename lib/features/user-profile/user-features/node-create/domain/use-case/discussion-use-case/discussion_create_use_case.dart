import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/repository/node_create_repository.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';

class DiscussionCreateUseCase extends UseCases<String, DiscussionCreateInput> {
  DiscussionCreateUseCase({
    required this.nodeCreateRepository,
  });

  final NodeCreateRepository nodeCreateRepository;

  @override
  FutureOr<String> call(DiscussionCreateInput params) async {
    return nodeCreateRepository.createNewDiscussion(params);
  }
}
