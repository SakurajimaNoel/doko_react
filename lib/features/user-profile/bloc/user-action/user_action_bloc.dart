import 'dart:async';
import 'dart:collection';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/use-case/comments/comment_add_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/comments/comment_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/comments/comment_remove_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/discussion/discussion_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_add_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_remove_like_use_case.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/input/post_input.dart';
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
  final DiscussionGetUseCase _discussionGetUseCase;
  final CommentGetUseCase _commentGetUseCase;

  UserActionBloc({
    required PostAddLikeUseCase postAddLikeUseCase,
    required PostRemoveLikeUseCase postRemoveLikeUseCase,
    required CommentAddLikeUseCase commentAddLikeUseCase,
    required CommentRemoveLikeUseCase commentRemoveLikeUseCase,
    required PostGetUseCase postGetUseCase,
    required DiscussionGetUseCase discussionGetUseCase,
    required CommentGetUseCase commentGetUseCase,
  })  : _postAddLikeUseCase = postAddLikeUseCase,
        _postRemoveLikeUseCase = postRemoveLikeUseCase,
        _commentAddLikeUseCase = commentAddLikeUseCase,
        _commentRemoveLikeUseCase = commentRemoveLikeUseCase,
        _postGetUseCase = postGetUseCase,
        _discussionGetUseCase = discussionGetUseCase,
        _commentGetUseCase = commentGetUseCase,
        super(UserActionInitial()) {
    on<UserActionPostLikeActionEvent>(_handleUserActionPostLikeActionEvent);
    on<UserActionTimelineLoadEvent>((event, emit) {
      emit(UserActionLoadTimelineState(
        itemCount: event.itemCount,
        username: event.username,
      ));
    });
    on<UserActionNewPostEvent>(
      (event, emit) => emit(
        UserActionNewPostState(
          nodeId: event.postId,
          username: event.username,
        ),
      ),
    );
    on<UserActionNewDiscussionEvent>(
      (event, emit) => emit(
        UserActionNewDiscussionState(
          nodeId: event.discussionId,
          username: event.username,
        ),
      ),
    );
    on<UserActionNewPollEvent>(
      (event, emit) => emit(
        UserActionNewPollState(
          nodeId: event.pollId,
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

      // send to websocket server
    });
    on<UserActionPrimaryNodeRefreshEvent>(
      (event, emit) => emit(
        UserActionPrimaryNodeRefreshState(
          nodeId: event.nodeId,
        ),
      ),
    );
    on<UserActionNewPostRemoteEvent>(_handleUserActionNewPostRemoteEvent);
    on<UserActionNewDiscussionRemoteEvent>(
        _handleUserActionNewDiscussionRemoteEvent);
    on<UserActionNewPollRemoteEvent>(_handleUserActionNewPollRemoteEvent);

    on<UserActionGetPostByIdEvent>(_handleUserActionGetPostByIdEvent);
    on<UserActionGetDiscussionByIdEvent>(
        _handleUserActionGetDiscussionByIdEvent);
    on<UserActionGetCommentByIdEvent>(_handleUserActionGetCommentByIdEvent);
    on<UserActionNodeLikeRemoteEvent>(_handleUserActionNodeLikeRemoteEvent);
    on<UserActionNodeHighlightEvent>(
      (event, emit) => emit(
        UserActionNodeHighlightState(
          nodeId: event.nodeId,
        ),
      ),
    );

    on<UserActionNewSecondaryNodeRemoteEvent>(
        _handleUserActionNewSecondaryNodeRemoteEvent);
  }

  FutureOr<void> _handleUserActionNewSecondaryNodeRemoteEvent(
      UserActionNewSecondaryNodeRemoteEvent event,
      Emitter<UserActionState> emit) async {
    /// update graph
    /// need to update post and comment based on parent
    /// if parents.first is post update post if comment update comment
    final parentNodeType =
        DokiNodeType.fromNodeType(event.payload.parents.first.nodeType);
    final parentNodeId = event.payload.parents.first.nodeId;

    final nodeId = event.payload.nodeId;

    graph.addCommentIdToPrimaryNode(
      parentNodeType.keyGenerator(parentNodeId),
      commentId: nodeId,
    );

    emit(UserActionNodeActionState(
      nodeId: event.payload.parents.first.nodeId,
      userLike: false,
      likesCount: 0,
      commentsCount: 0,
    ));

    emit(UserActionNewCommentState(
      nodeId: event.payload.parents.first.nodeId,
    ));
  }

  FutureOr<void> _handleUserActionNodeLikeRemoteEvent(
      UserActionNodeLikeRemoteEvent event,
      Emitter<UserActionState> emit) async {
    final UserNodeLikeAction payload = event.payload;
    final bool self = event.username == payload.from;

    // node type will always be post, comment or discussion
    if (payload.nodeType == NodeType.post) {
      graph.handleUserLikeActionForPostEntity(
        payload.nodeId,
        userLike: self ? payload.isLike : null,
        likesCount: payload.likeCount,
        commentsCount: payload.commentCount,
      );
    }

    if (payload.nodeType == NodeType.comment) {
      graph.handleUserLikeActionForCommentEntity(
        payload.nodeId,
        likesCount: payload.likeCount,
        commentsCount: payload.commentCount,
        userLike: self ? payload.isLike : null,
      );
    }

    emit(UserActionNodeActionState(
      nodeId: payload.nodeId,
      userLike: payload.isLike,
      likesCount: payload.likeCount,
      commentsCount: payload.commentCount,
    ));
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
      user.timeline.addItem(postKey);
    }

    emit(UserActionNewPostState(
      nodeId: event.postId,
      username: event.username,
    ));
  }

  FutureOr<void> _handleUserActionNewDiscussionRemoteEvent(
      UserActionNewDiscussionRemoteEvent event,
      Emitter<UserActionState> emit) async {
    // handle user graph
    String discussionKey = generateDiscussionNodeKey(event.discussionId);
    String userKey = generateUserNodeKey(event.username);
    final user = graph.getValueByKey(userKey);

    if (user is CompleteUserEntity) {
      if (!user.discussions.items.contains(discussionKey)) {
        // add to user post
        user.discussionCount++;
      }
      user.discussions.addItem(discussionKey);
      user.timeline.addItem(discussionKey);
    }

    emit(UserActionNewDiscussionState(
      nodeId: event.discussionId,
      username: event.username,
    ));
  }

  FutureOr<void> _handleUserActionNewPollRemoteEvent(
      UserActionNewPollRemoteEvent event, Emitter<UserActionState> emit) async {
    // handle user graph
    String pollKey = generatePollNodeKey(event.pollId);
    String userKey = generateUserNodeKey(event.username);
    final user = graph.getValueByKey(userKey);

    if (user is CompleteUserEntity) {
      if (!user.polls.items.contains(pollKey)) {
        // add to user post
        user.pollCount++;
      }
      user.polls.addItem(pollKey);
      user.timeline.addItem(pollKey);
    }

    emit(UserActionNewPollState(
      nodeId: event.pollId,
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

      UserNodeLikeAction payload = event.remotePayload.copyWith(
        likeCount: post.likesCount,
        commentCount: post.commentsCount,
        isLike: post.userLike,
      );
      event.client?.sendPayload(payload);
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

      UserNodeLikeAction payload = event.remotePayload.copyWith(
        isLike: comment.userLike,
        likeCount: comment.likesCount,
        commentCount: comment.commentsCount,
      );
      event.client?.sendPayload(payload);
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

  FutureOr<void> _handleUserActionGetDiscussionByIdEvent(
      UserActionGetDiscussionByIdEvent event,
      Emitter<UserActionState> emit) async {
    try {
      if (getNodeRequest.contains(event.discussionId)) return;

      String key = generateDiscussionNodeKey(event.discussionId);
      if (graph.containsKey(key)) return;

      getNodeRequest.add(event.discussionId);
      await _discussionGetUseCase(GetNodeInput(
        username: event.username,
        nodeId: event.discussionId,
      ));

      getNodeRequest.remove(event.discussionId);
      emit(UserActionDiscussionDataFetchedState(
        discussionId: event.discussionId,
        success: true,
      ));
    } catch (_) {
      emit(UserActionDiscussionDataFetchedState(
        discussionId: event.discussionId,
        success: false,
      ));
    }
    getNodeRequest.remove(event.discussionId);
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
