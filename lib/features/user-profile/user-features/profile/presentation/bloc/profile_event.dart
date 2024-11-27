part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class GetUserProfileEvent extends ProfileEvent {
  GetUserProfileEvent({required this.userDetails});

  final GetProfileInput userDetails;
}
