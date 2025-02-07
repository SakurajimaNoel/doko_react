import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/use-case/comments-use-case/comments_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/use-case/comments-use-case/replies_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/use-case/post-use-case/post_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'root_node_event.dart';
part 'root_node_state.dart';

class RootNodeBloc extends Bloc<RootNodeEvent, RootNodeState> {
  final UserGraph graph = UserGraph();

  final PostUseCase _postUseCase;
  final CommentsUseCase _commentsUseCase;
  final RepliesUseCase _repliesUseCase;

  RootNodeBloc({
    required PostUseCase postUseCase,
    required CommentsUseCase commentsUseCase,
    required RepliesUseCase repliesUseCase,
  })  : _postUseCase = postUseCase,
        _commentsUseCase = commentsUseCase,
        _repliesUseCase = repliesUseCase,
        super(RootNodeLoading()) {
    on<PostLoadEvent>(_handlePostLoadEvent);
    on<CommentLoadEvent>(_handleCommentLoadEvent);
    on<LoadMoreCommentEvent>(_handleLoadMoreCommentEvent);
    on<LoadCommentReplyEvent>(_handleCommentReplyEvent);
    on<PostRefreshEvent>(_handlePostRefreshEvent);
  }

  FutureOr<void> _handlePostLoadEvent(
      PostLoadEvent event, Emitter<RootNodeState> emit) async {
    try {
      String postId = event.details.nodeId;
      String postKey = generatePostNodeKey(postId);

      if (graph.containsKey(postKey)) {
        /// post exists no need to refetch
        /// check if comments are present or not
        final PostEntity post = graph.getValueByKey(postKey)! as PostEntity;

        if (post.comments.isEmpty) {
          add(CommentLoadEvent(
            details: GetCommentsInput(
              nodeId: postId,
              username: event.details.username,
              isPost: true,
              cursor: "",
            ),
          ));
        } else {
          emit(PostAndCommentSuccessState());
        }

        return;
      }

      await _postUseCase(event.details);
      emit(PostAndCommentSuccessState());
    } on ApplicationException catch (e) {
      emit(RootNodeErrorState(
        message: e.reason,
      ));
    } catch (e) {
      emit(RootNodeErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleCommentLoadEvent(
      CommentLoadEvent event, Emitter<RootNodeState> emit) async {
    try {
      emit(CommentLoadingState());

      await _commentsUseCase(event.details);
      emit(PostAndCommentSuccessState());
    } on ApplicationException catch (e) {
      emit(CommentErrorState(
        message: e.reason,
      ));
    } catch (e) {
      emit(CommentErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleLoadMoreCommentEvent(
      LoadMoreCommentEvent event, Emitter<RootNodeState> emit) async {
    try {
      String postKey = generatePostNodeKey(event.details.nodeId);
      final PostEntity entity = graph.getValueByKey(postKey)! as PostEntity;

      if (event.details.cursor.isEmpty && entity.comments.items.isNotEmpty) {
        emit(CommentLoadSuccess(
          loadedCommentCount: entity.comments.items.length,
        ));

        return;
      }

      await _commentsUseCase(event.details);
      emit(CommentLoadSuccess(
        loadedCommentCount: entity.comments.items.length,
      ));
    } on ApplicationException catch (e) {
      emit(LoadErrorState(
        message: e.reason,
        nodeId: event.details.nodeId,
      ));
    } catch (e) {
      emit(LoadErrorState(
        message: Constants.errorMessage,
        nodeId: event.details.nodeId,
      ));
    }
  }

  FutureOr<void> _handleCommentReplyEvent(
      LoadCommentReplyEvent event, Emitter<RootNodeState> emit) async {
    try {
      emit(CommentReplyLoadingState(
        commentId: event.details.nodeId,
      ));
      String commentKey = generateCommentNodeKey(event.details.nodeId);
      final CommentEntity entity =
          graph.getValueByKey(commentKey)! as CommentEntity;

      if (event.details.cursor.isEmpty &&
          entity.comments.items.length == entity.commentsCount) {
        emit(CommentReplyLoadSuccess(
          loadedReplyCount: entity.comments.items.length,
          commentId: event.details.nodeId,
        ));

        return;
      }

      await _repliesUseCase(event.details);
      emit(CommentReplyLoadSuccess(
        loadedReplyCount: entity.comments.items.length,
        commentId: event.details.nodeId,
      ));
    } on ApplicationException catch (e) {
      emit(LoadErrorState(
        message: e.reason,
        nodeId: event.details.nodeId,
      ));
    } catch (e) {
      emit(LoadErrorState(
        message: Constants.errorMessage,
        nodeId: event.details.nodeId,
      ));
    }
  }

  FutureOr<void> _handlePostRefreshEvent(
      PostRefreshEvent event, Emitter<RootNodeState> emit) async {
    try {
      await _postUseCase(event.details);
      emit(PostRefreshSuccessState());
    } on ApplicationException catch (e) {
      emit(PostRefreshErrorState(
        message: e.reason,
      ));
    } catch (e) {
      emit(PostRefreshErrorState(
        message: Constants.errorMessage,
      ));
    }
  }
}
