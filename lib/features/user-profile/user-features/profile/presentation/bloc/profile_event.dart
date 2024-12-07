part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class GetUserProfileEvent extends ProfileEvent {
  GetUserProfileEvent({
    required this.userDetails,
    bool? indirect,
  }) : indirect = indirect ?? false;

  final GetProfileInput userDetails;

  /// this is used when user is fetched
  /// when accessing pages that require
  /// complete user entity
  /// like friends page
  final bool indirect;
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

  final GetProfileInput userDetails;
}

final class LoadMoreProfileFriendsEvent extends ProfileEvent {
  LoadMoreProfileFriendsEvent({
    required this.friendDetails,
  });

  final UserProfileNodesInput friendDetails;
}
