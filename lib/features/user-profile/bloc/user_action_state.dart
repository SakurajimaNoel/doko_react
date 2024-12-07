part of 'user_action_bloc.dart';

@immutable
sealed class UserActionState extends Equatable {}

final class UserActionInitial extends UserActionState {
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

class UserActionNewPostState extends UserActionState {
  UserActionNewPostState() : date = DateTime.now();

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

// more friends action
class UserActionLoadFriends extends UserActionState {
  UserActionLoadFriends({
    required this.loadedFriendsCount,
    required this.username,
  });

  final String username;
  final int loadedFriendsCount;

  @override
  List<Object?> get props => [username, loadedFriendsCount];
}

/// user post action state
/// used when updating ui for post action
/// when new comment is added or like is changed
/// this will be used with both post and comment
class UserActionNodeActionState extends UserActionState {
  UserActionNodeActionState({
    required this.nodeId,
    required this.userLike,
    required this.likesCount,
    required this.commentsCount,
  });

  final String nodeId;
  final int likesCount;
  final bool userLike;
  final int commentsCount;

  @override
  List<Object?> get props => [nodeId, likesCount, userLike, commentsCount];
}

/// used in user to user relation widget
/// in user friends list
/// and self pending request
class UserActionUserRelationState extends UserActionState {
  UserActionUserRelationState({
    required this.username,
    required this.relation,
  });

  final String username;
  final UserToUserRelation relation;

  @override
  List<Object?> get props => [username, relation];
}

// user friend list updates
class UserActionUpdateUserAcceptedFriendsListState extends UserActionState {
  UserActionUpdateUserAcceptedFriendsListState({
    required this.currentUsername,
    required this.username,
  });

  final String currentUsername;
  final String username;

  @override
  List<Object?> get props => [username, currentUsername];
}

class UserActionUpdateUserPendingFriendsListState extends UserActionState {
  UserActionUpdateUserPendingFriendsListState({
    required this.currentUsername,
    required this.username,
  });

  final String currentUsername;
  final String username;

  @override
  List<Object?> get props => [username, currentUsername];
}
