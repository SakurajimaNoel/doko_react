import 'dart:async';
import 'dart:collection';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/use-case/comments/comment_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/discussion/discussion_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/poll/poll_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/poll/user_add_vote_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/posts/post_get.dart';
import 'package:doko_react/features/user-profile/domain/use-case/user-node-action/user_node_like_action_use_case.dart';
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
  final Set<String> pollAddVote = HashSet();

  final UserNodeLikeActionUseCase _userNodeLikeActionUseCase;
  final PostGetUseCase _postGetUseCase;
  final DiscussionGetUseCase _discussionGetUseCase;
  final PollGetUseCase _pollGetUseCase;
  final CommentGetUseCase _commentGetUseCase;
  final UserAddVoteUseCase _userAddVoteUseCase;

  UserActionBloc({
    required UserNodeLikeActionUseCase userNodeLikeActionUseCase,
    required PostGetUseCase postGetUseCase,
    required DiscussionGetUseCase discussionGetUseCase,
    required PollGetUseCase pollGetUseCase,
    required CommentGetUseCase commentGetUseCase,
    required UserAddVoteUseCase userAddVoteUseCase,
  })  : _userNodeLikeActionUseCase = userNodeLikeActionUseCase,
        _postGetUseCase = postGetUseCase,
        _discussionGetUseCase = discussionGetUseCase,
        _pollGetUseCase = pollGetUseCase,
        _commentGetUseCase = commentGetUseCase,
        _userAddVoteUseCase = userAddVoteUseCase,
        super(UserActionInitial()) {
    on<UserActionNodeLikeEvent>(_handleUserActionNodeLikeEvent);
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
          usersTagged: event.usersTagged,
        ),
      ),
    );
    on<UserActionNewDiscussionEvent>(
      (event, emit) => emit(
        UserActionNewDiscussionState(
          nodeId: event.discussionId,
          username: event.username,
          usersTagged: event.usersTagged,
        ),
      ),
    );
    on<UserActionNewPollEvent>(
      (event, emit) => emit(
        UserActionNewPollState(
          nodeId: event.pollId,
          username: event.username,
          usersTagged: event.usersTagged,
        ),
      ),
    );
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
    on<UserActionGetPollByIdEvent>(_handleUserActionGetPollByIdEvent);

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

    on<UserActionAddVoteToPollEvent>(_handleUserActionAddVoteToPollEvent);
  }

  FutureOr<void> _handleUserActionAddVoteToPollEvent(
      UserActionAddVoteToPollEvent event, Emitter<UserActionState> emit) async {
    String pollId = event.pollId;
    String username = event.username;
    PollOption option = event.option;

    if (pollAddVote.contains(pollId)) return;
    pollAddVote.add(pollId);

    final String pollKey = generatePollNodeKey(pollId);
    final poll = graph.getValueByKey(pollKey)! as PollEntity;
    final currVote = poll.userVote;

    try {
      // optimistic update
      poll.addVote(option.ind);
      emit(UserActionVoteAddSuccessState(
        pollId: pollId,
        commentCount: poll.commentsCount,
        likeCount: poll.likesCount,
        options: poll.options,
      ));
      await _userAddVoteUseCase(UserPollAddVoteInput(
        pollId: pollId,
        username: username,
        option: option,
      ));

      emit(UserActionVoteAddSuccessState(
        pollId: pollId,
        commentCount: poll.commentsCount,
        likeCount: poll.likesCount,
        options: poll.options,
      ));
    } catch (e) {
      // revert optimistic update
      if (currVote == null) {
        poll.removeVote();
      } else {
        poll.addVote(currVote.ind);
      }

      String errorMessage = Constants.errorMessage;
      if (e is ApplicationException) {
        errorMessage = e.reason;
      }
      emit(UserActionVoteAddFailureState(
        pollId: pollId,
        message: errorMessage,
      ));
    }

    pollAddVote.remove(pollId);
  }

  FutureOr<void> _handleUserActionNodeLikeEvent(
      UserActionNodeLikeEvent event, Emitter<UserActionState> emit) async {
    String nodeId = event.nodeId;
    DokiNodeType nodeType = event.nodeType;
    if (nodeLikeActionRequest.contains(nodeId)) return;

    nodeLikeActionRequest.add(nodeId);
    String nodeKey = nodeType.keyGenerator(nodeId);
    final node = graph.getValueByKey(nodeKey)! as GraphEntityWithUserAction;

    int initLike = node.likesCount;
    int newLike = event.userLike ? initLike + 1 : initLike - 1;

    try {
      // optimistic update
      graph.handleUserLikeAction(
        nodeKey: nodeKey,
        userLike: event.userLike,
        likesCount: newLike,
        commentsCount: node.commentsCount,
      );

      emit(UserActionNodeActionState(
        nodeId: nodeId,
        userLike: node.userLike,
        likesCount: node.likesCount,
        commentsCount: node.commentsCount,
      ));

      await _userNodeLikeActionUseCase(UserNodeLikeActionInput(
        nodeId: nodeId,
        username: event.username,
        userLike: event.userLike,
        nodeType: nodeType,
      ));

      emit(UserActionNodeActionState(
        nodeId: nodeId,
        userLike: node.userLike,
        likesCount: node.likesCount,
        commentsCount: node.commentsCount,
      ));

      UserNodeLikeAction payload = event.remotePayload.copyWith(
        likeCount: node.likesCount,
        commentCount: node.commentsCount,
        isLike: node.userLike,
      );
      event.client?.sendPayload(payload);
    } catch (_) {
      // optimistic failure revert
      graph.handleUserLikeAction(
        nodeKey: nodeKey,
        userLike: !event.userLike,
        likesCount: initLike,
        commentsCount: node.commentsCount,
      );

      emit(UserActionNodeActionState(
        nodeId: nodeId,
        userLike: node.userLike,
        likesCount: node.likesCount,
        commentsCount: node.commentsCount,
      ));
    }

    nodeLikeActionRequest.remove(nodeId);
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
      isReply: parentNodeType == DokiNodeType.comment,
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
    final nodeType = DokiNodeType.fromNodeType(payload.nodeType);

    graph.handleUserLikeAction(
      nodeKey: nodeType.keyGenerator(payload.nodeId),
      likesCount: payload.likeCount,
      commentsCount: payload.commentCount,
      userLike: self ? payload.isLike : null,
    );

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
    String userKey = generateUserNodeKey(event.nodeBy);
    final user = graph.getValueByKey(userKey);
    final List<String> usersTagged = event.usersTagged;

    if (user is CompleteUserEntity) {
      if (!user.posts.items.contains(postKey)) {
        // add to user post
        user.postsCount++;
      }
      user.posts.addItem(postKey);
      user.timeline.addItem(postKey);
    }

    for (String user in usersTagged) {
      String key = generateUserNodeKey(user);
      final node = graph.getValueByKey(key);

      if (node is CompleteUserEntity) {
        node.timeline.addItem(postKey);
      }
    }

    emit(UserActionNewPostState(
      nodeId: event.postId,
      username: event.nodeBy,
      usersTagged: usersTagged,
    ));
  }

  FutureOr<void> _handleUserActionNewDiscussionRemoteEvent(
      UserActionNewDiscussionRemoteEvent event,
      Emitter<UserActionState> emit) async {
    // handle user graph
    String discussionKey = generateDiscussionNodeKey(event.discussionId);
    String userKey = generateUserNodeKey(event.nodeBy);
    final user = graph.getValueByKey(userKey);
    final List<String> usersTagged = event.usersTagged;

    if (user is CompleteUserEntity) {
      if (!user.discussions.items.contains(discussionKey)) {
        // add to user post
        user.discussionCount++;
      }
      user.discussions.addItem(discussionKey);
      user.timeline.addItem(discussionKey);
    }

    for (String user in usersTagged) {
      String key = generateUserNodeKey(user);
      final node = graph.getValueByKey(key);

      if (node is CompleteUserEntity) {
        node.timeline.addItem(discussionKey);
      }
    }

    emit(UserActionNewDiscussionState(
      nodeId: event.discussionId,
      username: event.nodeBy,
      usersTagged: usersTagged,
    ));
  }

  FutureOr<void> _handleUserActionNewPollRemoteEvent(
      UserActionNewPollRemoteEvent event, Emitter<UserActionState> emit) async {
    // handle user graph
    String pollKey = generatePollNodeKey(event.pollId);
    String userKey = generateUserNodeKey(event.nodeBy);
    final user = graph.getValueByKey(userKey);
    final List<String> usersTagged = event.usersTagged;

    if (user is CompleteUserEntity) {
      if (!user.polls.items.contains(pollKey)) {
        // add to user post
        user.pollCount++;
      }
      user.polls.addItem(pollKey);
      user.timeline.addItem(pollKey);
    }

    for (String user in usersTagged) {
      String key = generateUserNodeKey(user);
      final node = graph.getValueByKey(key);

      if (node is CompleteUserEntity) {
        node.timeline.addItem(pollKey);
      }
    }

    emit(UserActionNewPollState(
      nodeId: event.pollId,
      username: event.nodeBy,
      usersTagged: usersTagged,
    ));
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
      emit(UserActionNodeDataFetchedState(
        nodeId: event.postId,
        success: true,
      ));
    } catch (_) {
      emit(UserActionNodeDataFetchedState(
        nodeId: event.postId,
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
      emit(UserActionNodeDataFetchedState(
        nodeId: event.discussionId,
        success: true,
      ));
    } catch (_) {
      emit(UserActionNodeDataFetchedState(
        nodeId: event.discussionId,
        success: false,
      ));
    }
    getNodeRequest.remove(event.discussionId);
  }

  FutureOr<void> _handleUserActionGetPollByIdEvent(
      UserActionGetPollByIdEvent event, Emitter<UserActionState> emit) async {
    try {
      if (getNodeRequest.contains(event.pollId)) return;

      String key = generatePollNodeKey(event.pollId);
      if (graph.containsKey(key)) return;

      getNodeRequest.add(event.pollId);
      await _pollGetUseCase(GetNodeInput(
        username: event.username,
        nodeId: event.pollId,
      ));

      getNodeRequest.remove(event.pollId);
      emit(UserActionNodeDataFetchedState(
        nodeId: event.pollId,
        success: true,
      ));
    } catch (_) {
      emit(UserActionNodeDataFetchedState(
        nodeId: event.pollId,
        success: false,
      ));
    }
    getNodeRequest.remove(event.pollId);
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
