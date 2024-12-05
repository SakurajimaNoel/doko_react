import 'dart:async';

import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_add_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_remove_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'user_action_event.dart';
part 'user_action_state.dart';

class UserActionBloc extends Bloc<UserActionEvent, UserActionState> {
  final UserGraph graph = UserGraph();
  final PostAddLikeUseCase _postAddLikeUseCase;
  final PostRemoveLikeUseCase _postRemoveLikeUseCase;

  UserActionBloc(
      {required PostAddLikeUseCase postAddLikeUseCase,
      required PostRemoveLikeUseCase postRemoveLikeUseCase})
      : _postAddLikeUseCase = postAddLikeUseCase,
        _postRemoveLikeUseCase = postRemoveLikeUseCase,
        super(UserActionInitial()) {
    on<UserActionUpdateEvent>(_handleUserActionUpdateEvent);
    on<UserActionPostLikeActionEvent>(_handleUserActionPostLikeActionEvent);
  }

  FutureOr<void> _handleUserActionUpdateEvent(
      UserActionUpdateEvent event, Emitter<UserActionState> emit) {
    emit(UserActionUpdateProfile(
      name: event.name,
      bio: event.bio,
      profilePicture: event.profilePicture,
    ));
  }

  FutureOr<void> _handleUserActionPostLikeActionEvent(
      UserActionPostLikeActionEvent event,
      Emitter<UserActionState> emit) async {
    String postKey = generatePostNodeKey(event.postId);
    PostEntity post = graph.getValueByKey(postKey)! as PostEntity;

    int initLike = post.likesCount;
    int newLike = event.userLike ? initLike + 1 : initLike - 1;

    try {
      // optimistic update
      graph.handleUserLikeActionForPostEntity(
        event.postId,
        userLike: event.userLike,
        likesCount: newLike,
        commentsCount: post.commentsCount,
      );

      emit(UserActionNodeActionState(
        nodeId: post.id,
        userLike: post.userLike,
        likesCount: post.likesCount,
        commentsCount: post.commentsCount,
      ));

      if (event.userLike) {
        await _postAddLikeUseCase(UserPostLikeActionInput(
          postId: event.postId,
          username: event.username,
        ));
      } else {
        await _postRemoveLikeUseCase(UserPostLikeActionInput(
          postId: event.postId,
          username: event.username,
        ));
      }

      emit(UserActionNodeActionState(
        nodeId: post.id,
        userLike: post.userLike,
        likesCount: post.likesCount,
        commentsCount: post.commentsCount,
      ));
    } catch (_) {
      // optimistic failure revert
      graph.handleUserLikeActionForPostEntity(
        event.postId,
        userLike: !event.userLike,
        likesCount: initLike,
        commentsCount: post.commentsCount,
      );

      emit(UserActionNodeActionState(
        nodeId: post.id,
        userLike: post.userLike,
        likesCount: post.likesCount,
        commentsCount: post.commentsCount,
      ));
    }
  }
}
