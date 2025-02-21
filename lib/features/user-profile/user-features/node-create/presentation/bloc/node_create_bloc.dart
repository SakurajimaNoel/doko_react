import 'dart:async';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/use-case/comment-use-case/create_comment_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/use-case/discussion-use-case/discussion_create_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/use-case/poll-use-case/poll_create_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/use-case/post-create-use-case/post_create_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/comment_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/poll_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'node_create_event.dart';
part 'node_create_state.dart';

class NodeCreateBloc extends Bloc<NodeCreateEvent, NodeCreateState> {
  final UserGraph graph = UserGraph();

  final PostCreateUseCase _postCreateUseCase;
  final CreateCommentUseCase _createCommentUseCase;
  final DiscussionCreateUseCase _discussionCreateUseCase;
  final PollCreateUseCase _pollCreateUseCase;

  NodeCreateBloc({
    required PostCreateUseCase postCreateUseCase,
    required CreateCommentUseCase createCommentUseCase,
    required DiscussionCreateUseCase createDiscussionUseCase,
    required PollCreateUseCase pollCreateUseCase,
  })  : _postCreateUseCase = postCreateUseCase,
        _createCommentUseCase = createCommentUseCase,
        _discussionCreateUseCase = createDiscussionUseCase,
        _pollCreateUseCase = pollCreateUseCase,
        super(NodeCreateInitial()) {
    on<PostCreateEvent>(_handlePostCreateEvent);
    on<CreateCommentEvent>(_handleCreateCommentEvent);
    on<DiscussionCreateEvent>(_handleDiscussionCreateEvent);
    on<PollCreateEvent>(_handlePollCreateEvent);
  }

  FutureOr<void> _handlePollCreateEvent(
      PollCreateEvent event, Emitter<NodeCreateState> emit) async {
    try {
      emit(NodeCreateLoading());

      String pollId = await _pollCreateUseCase(event.pollDetails);
      emit(NodeCreateSuccess(
        nodeId: pollId,
      ));
    } on ApplicationException catch (e) {
      emit(NodeCreateError(
        message: e.reason,
      ));
    } catch (_) {
      emit(NodeCreateError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleDiscussionCreateEvent(
      DiscussionCreateEvent event, Emitter<NodeCreateState> emit) async {
    try {
      emit(NodeCreateLoading());

      String discussionId =
          await _discussionCreateUseCase(event.discussionDetails);
      emit(NodeCreateSuccess(
        nodeId: discussionId,
      ));
    } on ApplicationException catch (e) {
      emit(NodeCreateError(
        message: e.reason,
      ));
    } catch (_) {
      emit(NodeCreateError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handlePostCreateEvent(
      PostCreateEvent event, Emitter<NodeCreateState> emit) async {
    try {
      emit(NodeCreateLoading());

      String postId = await _postCreateUseCase(event.postDetails);
      emit(NodeCreateSuccess(
        nodeId: postId,
      ));
    } on ApplicationException catch (e) {
      emit(NodeCreateError(
        message: e.reason,
      ));
    } catch (_) {
      emit(NodeCreateError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleCreateCommentEvent(
      CreateCommentEvent event, Emitter<NodeCreateState> emit) async {
    try {
      emit(NodeCreateLoading());

      String commentId = await _createCommentUseCase(event.commentDetails);
      emit(NodeCreateSuccess(
        nodeId: commentId,
      ));

      final commentKey = generateCommentNodeKey(commentId);
      final comment = graph.getValueByKey(commentKey);

      if (comment is CommentEntity) {
        // remote send event
        UserCreateSecondaryNode payload = event.remotePayload.copyWith(
          nodeId: commentId,
        );
        event.client?.sendPayload(payload);
      }
    } on ApplicationException catch (e) {
      emit(NodeCreateError(
        message: e.reason,
      ));
    } catch (_) {
      emit(NodeCreateError(
        message: Constants.errorMessage,
      ));
    }
  }
}
