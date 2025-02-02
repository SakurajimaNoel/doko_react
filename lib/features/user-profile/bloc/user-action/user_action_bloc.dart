import 'dart:async';
import 'dart:collection';

import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/use-case/comments/comment_add_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/comments/comment_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/comments/comment_remove_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_add_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_remove_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'user_action_event.dart';
part 'user_action_state.dart';

class UserActionBloc extends Bloc<UserActionEvent, UserActionState> {
  final UserGraph graph = UserGraph();
  final Set<String> getNodeRequest = HashSet();
  final Set<String> nodeLikeActionRequest = HashSet();
  final Set<String> userToUserRelation = HashSet(); // currentUser@remoteUser

  final PostAddLikeUseCase _postAddLikeUseCase;
  final PostRemoveLikeUseCase _postRemoveLikeUseCase;
  final CommentAddLikeUseCase _commentAddLikeUseCase;
  final CommentRemoveLikeUseCase _commentRemoveLikeUseCase;
  final PostGetUseCase _postGetUseCase;
  final CommentGetUseCase _commentGetUseCase;

  UserActionBloc({
    required PostAddLikeUseCase postAddLikeUseCase,
    required PostRemoveLikeUseCase postRemoveLikeUseCase,
    required CommentAddLikeUseCase commentAddLikeUseCase,
    required CommentRemoveLikeUseCase commentRemoveLikeUseCase,
    required PostGetUseCase postGetUseCase,
    required CommentGetUseCase commentGetUseCase,
  })  : _postAddLikeUseCase = postAddLikeUseCase,
        _postRemoveLikeUseCase = postRemoveLikeUseCase,
        _commentAddLikeUseCase = commentAddLikeUseCase,
        _commentRemoveLikeUseCase = commentRemoveLikeUseCase,
        _postGetUseCase = postGetUseCase,
        _commentGetUseCase = commentGetUseCase,
        super(UserActionInitial()) {
    on<UserActionPostLikeActionEvent>(_handleUserActionPostLikeActionEvent);
    on<UserActionPostLoadEvent>((event, emit) {
      emit(UserActionLoadPosts(
        loadedPostCount: event.postCount,
        username: event.username,
      ));
    });
    on<UserActionNewPostEvent>(
      (event, emit) => emit(
        UserActionNewPostState(
          postId: event.postId,
          username: event.username,
        ),
      ),
    );
    on<UserActionCommentLikeActionEvent>(
        _handleUserActionCommentLikeActionEvent);
    on<UserActionNewCommentEvent>((event, emit) {
      emit(UserActionNodeActionState(
        nodeId: event.targetId,
        userLike: event.userLike,
        likesCount: event.likesCount,
        commentsCount: event.commentsCount,
      ));

      emit(UserActionNewCommentState(
        nodeId: event.targetId,
      ));
    });
    on<UserActionPostRefreshEvent>(
      (event, emit) => emit(
        UserActionPostRefreshState(
          nodeId: event.postId,
        ),
      ),
    );
    on<UserActionNewPostRemoteEvent>(_handleUserActionNewPostRemoteEvent);

    on<UserActionGetPostByIdEvent>(_handleUserActionGetPostByIdEvent);
    on<UserActionGetCommentByIdEvent>(_handleUserActionGetCommentByIdEvent);
  }

  FutureOr<void> _handleUserActionNewPostRemoteEvent(
      UserActionNewPostRemoteEvent event, Emitter<UserActionState> emit) async {
    // handle user graph
    String postKey = generatePostNodeKey(event.postId);
    String userKey = generateUserNodeKey(event.username);
    final user = graph.getValueByKey(userKey);

    if (user is CompleteUserEntity) {
      if (!user.posts.items.contains(postKey)) {
        // add to user post
        user.postsCount++;
      }
      user.posts.addItem(postKey);
    }

    emit(UserActionNewPostState(
      postId: event.postId,
      username: event.username,
    ));
  }

  FutureOr<void> _handleUserActionPostLikeActionEvent(
      UserActionPostLikeActionEvent event,
      Emitter<UserActionState> emit) async {
    String postId = event.postId;
    if (nodeLikeActionRequest.contains(postId)) return;

    nodeLikeActionRequest.add(postId);
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
        await _postAddLikeUseCase(UserNodeLikeActionInput(
          nodeId: event.postId,
          username: event.username,
        ));
      } else {
        await _postRemoveLikeUseCase(UserNodeLikeActionInput(
          nodeId: event.postId,
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

    nodeLikeActionRequest.remove(postId);
  }

  FutureOr<void> _handleUserActionCommentLikeActionEvent(
      UserActionCommentLikeActionEvent event,
      Emitter<UserActionState> emit) async {
    String commentId = event.commentId;
    if (nodeLikeActionRequest.contains(commentId)) return;

    nodeLikeActionRequest.add(commentId);

    String commentKey = generateCommentNodeKey(event.commentId);
    CommentEntity comment = graph.getValueByKey(commentKey)! as CommentEntity;

    int initLike = comment.likesCount;
    int newLike = event.userLike ? initLike + 1 : initLike - 1;

    try {
      // optimistic update
      graph.handleUserLikeActionForCommentEntity(
        event.commentId,
        userLike: event.userLike,
        likesCount: newLike,
        commentsCount: comment.commentsCount,
      );

      emit(UserActionNodeActionState(
        nodeId: comment.id,
        userLike: comment.userLike,
        likesCount: comment.likesCount,
        commentsCount: comment.commentsCount,
      ));

      if (event.userLike) {
        await _commentAddLikeUseCase(UserNodeLikeActionInput(
          nodeId: event.commentId,
          username: event.username,
        ));
      } else {
        await _commentRemoveLikeUseCase(UserNodeLikeActionInput(
          nodeId: event.commentId,
          username: event.username,
        ));
      }

      emit(UserActionNodeActionState(
        nodeId: comment.id,
        userLike: comment.userLike,
        likesCount: comment.likesCount,
        commentsCount: comment.commentsCount,
      ));
    } catch (_) {
      // optimistic failure revert
      graph.handleUserLikeActionForCommentEntity(
        event.commentId,
        userLike: !event.userLike,
        likesCount: initLike,
        commentsCount: comment.commentsCount,
      );

      emit(UserActionNodeActionState(
        nodeId: comment.id,
        userLike: comment.userLike,
        likesCount: comment.likesCount,
        commentsCount: comment.commentsCount,
      ));
    }

    nodeLikeActionRequest.remove(commentId);
  }

  FutureOr<void> _handleUserActionGetPostByIdEvent(
      UserActionGetPostByIdEvent event, Emitter<UserActionState> emit) async {
    try {
      if (getNodeRequest.contains(event.postId)) return;

      String key = generatePostNodeKey(event.postId);
      if (graph.containsKey(key)) return;

      getNodeRequest.add(event.postId);
      await _postGetUseCase(GetNodeInput(
        username: event.username,
        nodeId: event.postId,
      ));

      getNodeRequest.remove(event.postId);
      emit(UserActionPostDataFetchedState(
        postId: event.postId,
        success: true,
      ));
    } catch (_) {
      emit(UserActionPostDataFetchedState(
        postId: event.postId,
        success: false,
      ));
    }
    getNodeRequest.remove(event.postId);
  }

  FutureOr<void> _handleUserActionGetCommentByIdEvent(
      UserActionGetCommentByIdEvent event,
      Emitter<UserActionState> emit) async {
    try {
      if (getNodeRequest.contains(event.commentId)) return;

      String key = generateCommentNodeKey(event.commentId);
      if (graph.containsKey(key)) return;

      getNodeRequest.add(event.commentId);
      await _commentGetUseCase(GetNodeInput(
        username: event.username,
        nodeId: event.commentId,
      ));

      emit(UserActionCommentDataFetchedState(
        commentId: event.commentId,
        success: true,
      ));
    } catch (_) {
      emit(UserActionCommentDataFetchedState(
        commentId: event.commentId,
        success: false,
      ));
    }
    getNodeRequest.remove(event.commentId);
  }
}
