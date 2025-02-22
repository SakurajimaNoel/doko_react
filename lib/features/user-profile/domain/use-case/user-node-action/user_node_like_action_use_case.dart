import 'dart:async';

import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/domain/repository/user_profile_repository.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';

class UserNodeLikeActionUseCase
    extends UseCases<bool, UserNodeLikeActionInput> {
  UserNodeLikeActionUseCase({required this.profileRepository});

  final UserProfileRepository profileRepository;

  @override
  FutureOr<bool> call(UserNodeLikeActionInput params) async {
    final nodeType = params.nodeType;
    final nodeId = params.nodeId;
    final username = params.username;

    if (params.userLike) {
      // handle user like based on node type
      if (nodeType == DokiNodeType.post) {
        return profileRepository.userAddPostLike(nodeId, username);
      }
      if (nodeType == DokiNodeType.discussion) {
        return profileRepository.userAddDiscussionLike(nodeId, username);
      }
      if (nodeType == DokiNodeType.poll) {
        return profileRepository.userAddPollLike(nodeId, username);
      }

      return profileRepository.userAddCommentLike(nodeId, username);
    }

    if (nodeType == DokiNodeType.post) {
      return profileRepository.userRemovePostLike(nodeId, username);
    }
    if (nodeType == DokiNodeType.discussion) {
      return profileRepository.userRemoveDiscussionLike(nodeId, username);
    }
    if (nodeType == DokiNodeType.poll) {
      return profileRepository.userRemovePollLike(nodeId, username);
    }

    return profileRepository.userRemoveCommentLike(nodeId, username);
  }
}
