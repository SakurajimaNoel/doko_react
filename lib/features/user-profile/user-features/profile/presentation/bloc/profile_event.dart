part of 'profile_bloc.dart';

enum IndirectProfileFetch {
  friends,
  posts,
  discussions,
  polls,
  direct,
}

@immutable
sealed class ProfileEvent {}

final class GetUserProfileEvent extends ProfileEvent {
  GetUserProfileEvent({
    required this.userDetails,
    IndirectProfileFetch? indirect,
  }) : indirect = indirect ?? IndirectProfileFetch.direct;

  final UserProfileNodesInput userDetails;

  /// this is used when user is fetched
  /// when accessing pages that require
  /// complete user entity
  /// like friends page
  final IndirectProfileFetch indirect;
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

final class LoadUserTimelineNodesEvent extends ProfileEvent {
  LoadUserTimelineNodesEvent({
    required this.timelineDetails,
  });

  final UserProfileNodesInput timelineDetails;
}

// user posts fetching
final class GetUserPostsEvent extends ProfileEvent {
  GetUserPostsEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
}

final class GetUserPostsRefreshEvent extends ProfileEvent {
  GetUserPostsRefreshEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
}

// user discussion fetching
final class GetUserDiscussionEvent extends ProfileEvent {
  GetUserDiscussionEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
}

final class GetUserDiscussionRefreshEvent extends ProfileEvent {
  GetUserDiscussionRefreshEvent({
    required this.userDetails,
  });

  final UserProfileNodesInput userDetails;
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
final class GetUserPendingIncomingRequest extends ProfileEvent {
  GetUserPendingIncomingRequest({
    required this.username,
    this.cursor = "",
    bool? refresh,
  }) : refetch = refresh ?? false;

  final String username;
  final bool refetch;
  final String cursor;
}

final class GetUserPendingOutgoingRequest extends ProfileEvent {
  GetUserPendingOutgoingRequest({
    required this.username,
    this.cursor = "",
    bool? refresh,
  }) : refetch = refresh ?? false;

  final String username;
  final bool refetch;
  final String cursor;
}

// comment search
final class CommentMentionSearchEvent extends ProfileEvent {
  CommentMentionSearchEvent({
    required this.searchDetails,
  });

  final UserSearchInput searchDetails;
}
