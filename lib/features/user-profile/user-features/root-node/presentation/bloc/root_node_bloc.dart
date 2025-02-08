import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/use-case/comments-use-case/comments_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/domain/use-case/comments-use-case/comments_with_replies_use_case.dart';
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
  final CommentsWithRepliesUseCase _commentsWithRepliesUseCase;

  RootNodeBloc({
    required PostUseCase postUseCase,
    required CommentsUseCase commentsUseCase,
    required CommentsWithRepliesUseCase commentsWithRepliesUseCase,
  })  : _postUseCase = postUseCase,
        _commentsUseCase = commentsUseCase,
        _commentsWithRepliesUseCase = commentsWithRepliesUseCase,
        super(RootNodeLoading()) {
    on<PostLoadEvent>(_handlePostLoadEvent);
    on<SecondaryNodeLoadEvent>(_handleSecondaryNodeLoadEvent);
    on<LoadMoreSecondaryNodesEvent>(_handleLoadMoreSecondaryNodesEvent);

    on<PostRefreshEvent>(_handlePostRefreshEvent);
    on<CommentLoadEvent>(_handleCommentLoadEvent);
    on<CommentRefreshEvent>(_handleCommentRefreshEvent);
  }

  FutureOr<void> _handleCommentLoadEvent(
      CommentLoadEvent event, Emitter<RootNodeState> emit) async {
    try {
      String commentId = event.details.nodeId;
      String commentKey = generateCommentNodeKey(commentId);

      if (graph.containsKey(commentKey)) {
        /// comment exists no need to refetch
        /// check if comments are present or not
        final CommentEntity comment =
            graph.getValueByKey(commentKey)! as CommentEntity;

        if (comment.comments.isEmpty) {
          add(SecondaryNodeLoadEvent(
            details: GetCommentsInput(
              nodeId: commentId,
              username: event.details.username,
              nodeType: DokiNodeType.comment,
              cursor: "",
            ),
          ));
        } else {
          emit(PrimaryAndSecondaryNodeSuccessState());
        }

        return;
      }

      await _commentsWithRepliesUseCase(event.details);
      emit(PrimaryAndSecondaryNodeSuccessState());
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
          add(SecondaryNodeLoadEvent(
            details: GetCommentsInput(
              nodeId: postId,
              username: event.details.username,
              nodeType: DokiNodeType.post,
              cursor: "",
            ),
          ));
        } else {
          emit(PrimaryAndSecondaryNodeSuccessState());
        }

        return;
      }

      await _postUseCase(event.details);
      emit(PrimaryAndSecondaryNodeSuccessState());
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

  FutureOr<void> _handleSecondaryNodeLoadEvent(
      SecondaryNodeLoadEvent event, Emitter<RootNodeState> emit) async {
    try {
      emit(SecondaryLoadingState());

      await _commentsUseCase(event.details);
      emit(PrimaryAndSecondaryNodeSuccessState());
    } on ApplicationException catch (e) {
      emit(SecondaryNodeErrorState(
        message: e.reason,
      ));
    } catch (e) {
      emit(SecondaryNodeErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleLoadMoreSecondaryNodesEvent(
      LoadMoreSecondaryNodesEvent event, Emitter<RootNodeState> emit) async {
    try {
      final nodeType = event.details.nodeType;
      String graphKey = nodeType.keyGenerator(event.details.nodeId);
      final NodeWithCommentEntity entity =
          graph.getValueByKey(graphKey)! as NodeWithCommentEntity;

      if (event.details.cursor.isEmpty &&
          entity.nodeComments.items.isNotEmpty) {
        emit(SecondaryLoadSuccess(
          loadedCommentCount: entity.nodeComments.items.length,
        ));

        return;
      }

      await _commentsUseCase(event.details);
      emit(SecondaryLoadSuccess(
        loadedCommentCount: entity.nodeComments.items.length,
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
      emit(PrimaryNodeRefreshSuccessState());
    } on ApplicationException catch (e) {
      emit(PrimaryNodeRefreshErrorState(
        message: e.reason,
      ));
    } catch (e) {
      emit(PrimaryNodeRefreshErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleCommentRefreshEvent(
      CommentRefreshEvent event, Emitter<RootNodeState> emit) async {
    try {
      await _commentsWithRepliesUseCase(event.details);
      emit(PrimaryNodeRefreshSuccessState());
    } on ApplicationException catch (e) {
      emit(PrimaryNodeRefreshErrorState(
        message: e.reason,
      ));
    } catch (e) {
      emit(PrimaryNodeRefreshErrorState(
        message: Constants.errorMessage,
      ));
    }
  }
}
