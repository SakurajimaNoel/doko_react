import 'dart:async';
import 'dart:collection';

import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
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
    // on<UserActionUpdateEvent>(_handleUserActionUpdateEvent);
    on<UserActionPostLikeActionEvent>(_handleUserActionPostLikeActionEvent);
    on<UserActionPostLoadEvent>((event, emit) {
      emit(UserActionLoadPosts(
        loadedPostCount: event.postCount,
        username: event.username,
      ));
    });
    // on<UserActionFriendLoadEvent>((event, emit) {
    //   emit(UserActionLoadFriends(
    //     loadedFriendsCount: event.friendsCount,
    //     username: event.username,
    //   ));
    // });
    // on<UserActionCreateFriendRelationEvent>(
    //     _handleUserActionCreateFriendRelation);
    // on<UserActionAcceptFriendRelationEvent>(
    //     _handleUserActionAcceptFriendRelation);
    // on<UserActionRemoveFriendRelationEvent>(
    //     _handleUserActionRemoveFriendRelation);
    // on<UserActionUserRefreshEvent>((event, emit) {
    //   emit(UserActionUserRefreshState(
    //     username: event.username,
    //   ));
    // });
    on<UserActionNewPostEvent>(
      (event, emit) => emit(
        UserActionNewPostState(
          postId: event.postId,
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

    // on<UserActionGetUserByUsernameEvent>(
    //     _handleUserActionGetUserByUsernameEvent);
    on<UserActionGetPostByIdEvent>(_handleUserActionGetPostByIdEvent);
    on<UserActionGetCommentByIdEvent>(_handleUserActionGetCommentByIdEvent);
  }

  // FutureOr<void> _handleUserActionUpdateEvent(
  //     UserActionUpdateEvent event, Emitter<UserActionState> emit) {
  //   emit(
  //     UserActionUpdateProfile(
  //       name: event.name,
  //       bio: event.bio,
  //       profilePicture: event.profilePicture,
  //     ),
  //   );
  // }

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

  // FutureOr<void> _handleUserActionCreateFriendRelation(
  //     UserActionCreateFriendRelationEvent event,
  //     Emitter<UserActionState> emit) async {
  //   String currentUsername = event.currentUsername;
  //   String username = event.username;
  //   String setKey = "$currentUsername@$username";
  //
  //   if (userToUserRelation.contains(setKey)) return;
  //
  //   userToUserRelation.add(setKey);
  //
  //   /// optimistically update only affected user relation status
  //   /// friends list, friends count and pending request list
  //   /// will be handled by data source
  //   String friendKey = generateUserNodeKey(event.username);
  //   final user = graph.getValueByKey(friendKey)! as UserEntity;
  //
  //   final initRelation = user.relationInfo;
  //
  //   try {
  //     UserToUserRelationDetails details = UserToUserRelationDetails(
  //       initiator: event.currentUsername,
  //       participant: event.username,
  //       username: event.username,
  //       currentUsername: event.currentUsername,
  //     );
  //
  //     final tempRelation = UserRelationInfo(
  //       requestedBy: details.currentUsername,
  //       status: FriendStatus.pending,
  //       addedOn: DateTime.now(),
  //     );
  //     user.updateRelationInfo(tempRelation);
  //     emit(UserActionUserRelationState(
  //       username: details.username,
  //       relation: UserToUserRelation.optimisticOutgoingReq,
  //     ));
  //
  //     await _userCreateFriendRelationUseCase(details);
  //
  //     emit(UserActionUserRelationState(
  //       username: details.username,
  //       relation: UserToUserRelation.outgoingReq,
  //     ));
  //
  //     // update current user pending list
  //     emit(UserActionUpdateUserPendingFriendsListState(
  //       currentUsername: details.currentUsername,
  //       username: details.username,
  //     ));
  //
  //     emit(UserActionUpdateUserAcceptedFriendsListState(
  //       currentUsername: details.currentUsername,
  //       username: details.username,
  //     ));
  //   } catch (_) {
  //     // optimistic failure
  //     user.updateRelationInfo(initRelation);
  //
  //     emit(UserActionUserRelationState(
  //       username: event.username,
  //       relation: getUserToUserRelation(
  //         initRelation,
  //         currentUsername: event.currentUsername,
  //       ),
  //     ));
  //   }
  //   userToUserRelation.remove(setKey);
  // }

  // FutureOr<void> _handleUserActionAcceptFriendRelation(
  //     UserActionAcceptFriendRelationEvent event,
  //     Emitter<UserActionState> emit) async {
  //   String currentUsername = event.currentUsername;
  //   String username = event.username;
  //   String setKey = "$currentUsername@$username";
  //
  //   if (userToUserRelation.contains(setKey)) return;
  //
  //   userToUserRelation.add(setKey);
  //
  //   /// optimistically update only affected user relation status
  //   /// friends list, friends count and pending request list
  //   /// will be handled by data source
  //   String friendKey = generateUserNodeKey(event.username);
  //   final user = graph.getValueByKey(friendKey)! as UserEntity;
  //
  //   final initRelation = user.relationInfo;
  //
  //   try {
  //     UserToUserRelationDetails details = UserToUserRelationDetails(
  //       initiator: event.requestedBy,
  //       participant: event.currentUsername,
  //       username: event.username,
  //       currentUsername: event.currentUsername,
  //     );
  //     final tempRelation = initRelation!.copyWith(
  //       status: FriendStatus.accepted,
  //     );
  //     user.updateRelationInfo(tempRelation);
  //     emit(UserActionUserRelationState(
  //       username: details.username,
  //       relation: UserToUserRelation.optimisticFriends,
  //     ));
  //
  //     await _userAcceptFriendRelationUseCase(details);
  //
  //     emit(UserActionUserRelationState(
  //       username: details.username,
  //       relation: UserToUserRelation.friends,
  //     ));
  //
  //     // update current user friends list and involved user friends list
  //     emit(UserActionUpdateUserPendingFriendsListState(
  //       currentUsername: details.currentUsername,
  //       username: details.username,
  //     ));
  //
  //     emit(UserActionUpdateUserAcceptedFriendsListState(
  //       currentUsername: details.currentUsername,
  //       username: details.username,
  //     ));
  //   } catch (_) {
  //     // optimistic failure
  //     user.updateRelationInfo(initRelation);
  //
  //     emit(UserActionUserRelationState(
  //       username: event.username,
  //       relation: getUserToUserRelation(
  //         initRelation,
  //         currentUsername: event.currentUsername,
  //       ),
  //     ));
  //   }
  //   userToUserRelation.remove(setKey);
  // }

  // FutureOr<void> _handleUserActionRemoveFriendRelation(
  //     UserActionRemoveFriendRelationEvent event,
  //     Emitter<UserActionState> emit) async {
  //   String currentUsername = event.currentUsername;
  //   String username = event.username;
  //   String setKey = "$currentUsername@$username";
  //
  //   if (userToUserRelation.contains(setKey)) return;
  //
  //   userToUserRelation.add(setKey);
  //
  //   /// optimistically update only affected user relation status
  //   /// friends list, friends count and pending request list
  //   /// will be handled by data source
  //   String friendKey = generateUserNodeKey(event.username);
  //   final user = graph.getValueByKey(friendKey)! as UserEntity;
  //
  //   final initRelation = user.relationInfo;
  //
  //   try {
  //     UserToUserRelationDetails details = UserToUserRelationDetails(
  //       initiator: event.requestedBy,
  //       participant: event.requestedBy == event.username
  //           ? event.currentUsername
  //           : event.username,
  //       username: event.username,
  //       currentUsername: event.currentUsername,
  //     );
  //
  //     user.updateRelationInfo(null);
  //     emit(UserActionUserRelationState(
  //       username: details.username,
  //       relation: UserToUserRelation.optimisticUnrelated,
  //     ));
  //
  //     await _userRemoveFriendRelationUseCase(details);
  //
  //     emit(UserActionUserRelationState(
  //       username: details.username,
  //       relation: UserToUserRelation.unrelated,
  //     ));
  //
  //     // update current user pending list, current user friend list and involved user friend list
  //     emit(UserActionUpdateUserPendingFriendsListState(
  //       currentUsername: details.currentUsername,
  //       username: details.username,
  //     ));
  //
  //     emit(UserActionUpdateUserAcceptedFriendsListState(
  //       currentUsername: details.currentUsername,
  //       username: details.username,
  //     ));
  //   } catch (_) {
  //     // optimistic failure
  //     user.updateRelationInfo(initRelation);
  //
  //     emit(UserActionUserRelationState(
  //       username: event.username,
  //       relation: getUserToUserRelation(
  //         initRelation,
  //         currentUsername: event.currentUsername,
  //       ),
  //     ));
  //   }
  //   userToUserRelation.remove(setKey);
  // }

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

  // FutureOr<void> _handleUserActionGetUserByUsernameEvent(
  //     UserActionGetUserByUsernameEvent event,
  //     Emitter<UserActionState> emit) async {
  //   try {
  //     if (getUserRequest.contains(event.username)) return;
  //
  //     String key = generateUserNodeKey(event.username);
  //     if (graph.containsKey(key)) return;
  //
  //     getUserRequest.add(event.username);
  //     await _userGetUseCase(GetProfileInput(
  //       username: event.username,
  //       currentUsername: event.currentUser,
  //     ));
  //
  //     getUserRequest.remove(event.username);
  //     emit(UserActionUserDataFetchedState(
  //       username: event.username,
  //     ));
  //   } catch (_) {}
  // }

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
