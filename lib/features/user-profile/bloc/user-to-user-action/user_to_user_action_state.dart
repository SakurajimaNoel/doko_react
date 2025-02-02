part of 'user_to_user_action_bloc.dart';

sealed class UserToUserActionState extends Equatable {
  const UserToUserActionState();
}

final class UserToUserActionInitial extends UserToUserActionState {
  @override
  List<Object> get props => [];
}

class UserToUserActionUpdateProfileState extends UserToUserActionState {
  const UserToUserActionUpdateProfileState({
    required this.username,
    required this.name,
    required this.bio,
    required this.profilePicture,
  });

  final String name;
  final String bio;
  final String profilePicture;
  final String username;

  @override
  List<Object?> get props => [name, bio, profilePicture, username];
}

class UserToUserActionLoadFriendsState extends UserToUserActionState {
  const UserToUserActionLoadFriendsState({
    required this.loadedFriendsCount,
    required this.username,
  });

  final String username;
  final int loadedFriendsCount;

  @override
  List<Object?> get props => [username, loadedFriendsCount];
}

/// used in user to user relation widget
/// in user friends list
/// and self pending request
class UserToUserActionUserRelationState extends UserToUserActionState {
  const UserToUserActionUserRelationState({
    required this.username,
    required this.relation,
  });

  final String username;
  final UserToUserRelation relation;

  @override
  List<Object?> get props => [username, relation];
}

class UserToUserActionUpdateUserPendingFriendsListState
    extends UserToUserActionState {
  const UserToUserActionUpdateUserPendingFriendsListState({
    required this.currentUsername,
    required this.username,
  });

  final String currentUsername;
  final String username;

  @override
  List<Object?> get props => [username, currentUsername];
}

class UserToUserActionUpdateUserAcceptedFriendsListState
    extends UserToUserActionState {
  const UserToUserActionUpdateUserAcceptedFriendsListState({
    required this.currentUsername,
    required this.username,
  });

  final String currentUsername;
  final String username;

  @override
  List<Object?> get props => [username, currentUsername];
}

class UserToUserActionUserRefreshState extends UserToUserActionState {
  UserToUserActionUserRefreshState({
    required this.username,
  }) : now = DateTime.now();

  final String username;
  final DateTime now;

  @override
  List<Object?> get props => [username, now];
}

class UserToUserActionUserDataFetchedState extends UserToUserActionState {
  UserToUserActionUserDataFetchedState({
    required this.username,
  }) : now = DateTime.now();

  final String username;
  final DateTime now;

  @override
  List<Object?> get props => [username, now];
}
