import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/repository/node_create_repository.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/comment_create_input.dart';

class CreateCommentUseCase implements UseCases<String, CommentCreateInput> {
  CreateCommentUseCase({
    required this.nodeCreateRepository,
  });

  final NodeCreateRepository nodeCreateRepository;

  @override
  FutureOr<String> call(CommentCreateInput params) {
    if (!params.validate()) {
      throw ApplicationException(
        reason: params.invalidateReason(),
      );
    }

    return nodeCreateRepository.createNewComment(params);
  }
}
