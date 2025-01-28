import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/bloc/event_transformer.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/use-case/comments-use-case/comments_mention_search_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/use-case/comments-use-case/comments_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/use-case/comments-use-case/replies_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/post/domain/use-case/post-use-case/post_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/post/input/post_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final UserGraph graph = UserGraph();

  final PostUseCase _postUseCase;
  final CommentsUseCase _commentsUseCase;
  final RepliesUseCase _repliesUseCase;
  final CommentsMentionSearchUseCase _commentsMentionSearchUseCase;

  PostBloc({
    required PostUseCase postUseCase,
    required CommentsUseCase commentsUseCase,
    required RepliesUseCase repliesUseCase,
    required CommentsMentionSearchUseCase commentMentionSearchUseCase,
  })  : _postUseCase = postUseCase,
        _commentsUseCase = commentsUseCase,
        _repliesUseCase = repliesUseCase,
        _commentsMentionSearchUseCase = commentMentionSearchUseCase,
        super(PostLoadingState()) {
    on<PostLoadEvent>(_handlePostLoadEvent);
    on<CommentLoadEvent>(_handleCommentLoadEvent);
    on<LoadMoreCommentEvent>(_handleLoadMoreCommentEvent);
    on<LoadCommentReplyEvent>(_handleCommentReplyEvent);
    on<CommentMentionSearchEvent>(
      _handleCommentMentionSearchEvent,
      transformer: debounce(
        const Duration(
          milliseconds: 500,
        ),
      ),
    );
    on<PostRefreshEvent>(_handlePostRefreshEvent);
  }

  FutureOr<void> _handlePostLoadEvent(
      PostLoadEvent event, Emitter<PostState> emit) async {
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
      emit(PostErrorState(
        message: e.reason,
      ));
    } catch (e) {
      emit(PostErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleCommentLoadEvent(
      CommentLoadEvent event, Emitter<PostState> emit) async {
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
      LoadMoreCommentEvent event, Emitter<PostState> emit) async {
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
      LoadCommentReplyEvent event, Emitter<PostState> emit) async {
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

  FutureOr<void> _handleCommentMentionSearchEvent(
      CommentMentionSearchEvent event, Emitter<PostState> emit) async {
    try {
      if (event.searchDetails.query.isEmpty) {
        emit(PostInitial());
        return;
      }

      emit(CommentSearchLoading());
      final searchResults =
          await _commentsMentionSearchUseCase(event.searchDetails);

      emit(CommentSearchSuccessState(
        query: event.searchDetails.query,
        searchResults: searchResults,
      ));
    } on ApplicationException catch (e) {
      emit(CommentSearchErrorState(
        message: e.reason,
      ));
    } catch (_) {
      emit(CommentSearchErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handlePostRefreshEvent(
      PostRefreshEvent event, Emitter<PostState> emit) async {
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
