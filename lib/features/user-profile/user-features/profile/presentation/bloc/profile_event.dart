part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class GetUserProfileEvent extends ProfileEvent {
  GetUserProfileEvent({
    required this.userDetails,
  });

  final GetProfileInput userDetails;
}

final class EditUserProfileEvent extends ProfileEvent {
  EditUserProfileEvent({
    required this.editDetails,
  });

  final EditProfileInput editDetails;
}

final class LoadMoreProfilePost extends ProfileEvent {
  LoadMoreProfilePost({
    required this.postDetails,
  });

  final UserProfilePostInput postDetails;
}
