import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/repository/node_create_repository.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';

class PostCreateUseCase extends UseCases<bool, PostCreateInput> {
  PostCreateUseCase({
    required this.nodeCreateRepository,
  });

  final NodeCreateRepository nodeCreateRepository;

  @override
  FutureOr<bool> call(PostCreateInput params) async {
    return nodeCreateRepository.createNewPost(params);
  }
}
