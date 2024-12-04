part of 'user_action_bloc.dart';

@immutable
sealed class UserActionState extends Equatable {}

final class UserActionInitial extends UserActionState {
  @override
  List<Object?> get props => [];
}

/// user post like action
class UserActionPostLikeAction extends UserActionState {
  @override
  List<Object?> get props => [];
}

final class UserActionPostAddLike extends UserActionPostLikeAction {
  UserActionPostAddLike({
    required this.postId,
  });

  final String postId;

  @override
  List<Object?> get props => [postId];
}

final class UserActionPostRemoveLike extends UserActionPostLikeAction {
  UserActionPostRemoveLike({
    required this.postId,
  });

  final String postId;

  @override
  List<Object?> get props => [postId];
}

final class UserActionPostAddComment extends UserActionState {
  UserActionPostAddComment({
    required this.postId,
  });

  final String postId;

  @override
  List<Object?> get props => [postId];
}

/// user comment like action
class UserActionCommentLikeAction extends UserActionState {
  @override
  List<Object?> get props => [];
}

final class UserActionCommentAddLike extends UserActionCommentLikeAction {
  UserActionCommentAddLike({
    required this.commentId,
  });

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

final class UserActionCommentRemoveLike extends UserActionCommentLikeAction {
  UserActionCommentRemoveLike({
    required this.commentId,
  });

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

final class UserActionCommentAddReply extends UserActionState {
  UserActionCommentAddReply({
    required this.commentId,
  });

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

/// user friend relation change
class UserActionFriendRelationChange extends UserActionState {
  UserActionFriendRelationChange({
    required this.friendUsername,
  });

  final String friendUsername;

  @override
  List<Object?> get props => [friendUsername];
}

class UserActionRemoveFriendRelation extends UserActionFriendRelationChange {
  UserActionRemoveFriendRelation({
    required super.friendUsername,
  });

  @override
  List<Object?> get props => [];
}

class UserActionSendFriendReq extends UserActionFriendRelationChange {
  UserActionSendFriendReq({
    required super.friendUsername,
  });

  @override
  List<Object?> get props => [];
}

class UserActionAcceptFriendReq extends UserActionFriendRelationChange {
  UserActionAcceptFriendReq({
    required super.friendUsername,
  });

  @override
  List<Object?> get props => [];
}

// edit profile action
class UserActionUpdateProfile extends UserActionState {
  UserActionUpdateProfile({
    required this.name,
    required this.bio,
    required this.profilePicture,
  });

  final String name;
  final String bio;
  final String profilePicture;

  @override
  List<Object?> get props => [name, bio, profilePicture];
}

// more post action
class UserActionLoadPosts extends UserActionState {
  UserActionLoadPosts({
    required this.loadedPostCount,
    required this.username,
  });

  final String username;
  final int loadedPostCount;

  @override
  List<Object?> get props => [username, loadedPostCount];
}
