part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class GetUserProfileEvent extends ProfileEvent {
  GetUserProfileEvent({
    required this.userDetails,
    bool? indirect,
  }) : indirect = indirect ?? false;

  final UserProfileNodesInput userDetails;

  /// this is used when user is fetched
  /// when accessing pages that require
  /// complete user entity
  /// like friends page
  final bool indirect;
}

final class GetUserProfileRefreshEvent extends ProfileEvent {
  GetUserProfileRefreshEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
}

final class EditUserProfileEvent extends ProfileEvent {
  EditUserProfileEvent({
    required this.editDetails,
  });

  final EditProfileInput editDetails;
}

final class LoadMoreProfilePostEvent extends ProfileEvent {
  LoadMoreProfilePostEvent({
    required this.postDetails,
  });

  final UserProfileNodesInput postDetails;
}

// user friends fetching
final class GetUserFriendsEvent extends ProfileEvent {
  GetUserFriendsEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
}

final class GetUserFriendsRefreshEvent extends ProfileEvent {
  GetUserFriendsRefreshEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
}

// final class LoadMoreProfileFriendsEvent extends ProfileEvent {
//   LoadMoreProfileFriendsEvent({
//     required this.friendDetails,
//   });
//
//   final UserProfileNodesInput friendDetails;
// }

// user search events
final class UserSearchEvent extends ProfileEvent {
  UserSearchEvent({
    required this.searchDetails,
  });

  final UserSearchInput searchDetails;
}

final class UserFriendsSearchEvent extends ProfileEvent {
  UserFriendsSearchEvent({
    required this.searchDetails,
  });

  final UserFriendsSearchInput searchDetails;
}

// user pending events
final class PendingIncomingRequestInitial extends ProfileEvent {
  PendingIncomingRequestInitial({
    required this.username,
    bool? refresh,
  }) : refetch = refresh ?? false;

  final String username;
  final bool refetch;
}

final class PendingOutgoingRequestInitial extends ProfileEvent {
  PendingOutgoingRequestInitial({
    required this.username,
    bool? refresh,
  }) : refetch = refresh ?? false;

  final String username;
  final bool refetch;
}

final class PendingIncomingRequestMore extends ProfileEvent {
  PendingIncomingRequestMore({
    required this.username,
    required this.cursor,
  });

  final String username;
  final String cursor;
}

final class PendingOutgoingRequestMore extends ProfileEvent {
  PendingOutgoingRequestMore({
    required this.username,
    required this.cursor,
  });

  final String username;
  final String cursor;
}

// comment search
final class CommentMentionSearchEvent extends ProfileEvent {
  CommentMentionSearchEvent({
    required this.searchDetails,
  });

  final UserSearchInput searchDetails;
}

// fetch user created by posts
final class GetUserPostsEvent extends ProfileEvent {
  GetUserPostsEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
}
