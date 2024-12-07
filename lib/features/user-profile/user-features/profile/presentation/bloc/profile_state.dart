part of 'profile_bloc.dart';

@immutable
sealed class ProfileState extends Equatable {}

final class ProfileInitial extends ProfileState {
  @override
  List<Object?> get props => [];
}

// used only in profile widget and initial loading of profile friends
final class ProfileLoading extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileSuccess extends ProfileState {
  ProfileSuccess() : time = DateTime.now();
  
  final DateTime time;

  @override
  List<Object?> get props => [time];
}

final class ProfileError extends ProfileState {
  ProfileError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileRefreshError extends ProfileState {
  ProfileRefreshError({
    required this.message,
  }) : time = DateTime.now();

  final String message;
  final DateTime time;

  @override
  List<Object?> get props => [message, time];
}

final class ProfileEditSuccess extends ProfileState {
  @override
  List<Object?> get props => [];
}

// used with user posts in profile page for infinite loading
class ProfilePostLoadResponse extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfilePostLoadError extends ProfilePostLoadResponse {
  ProfilePostLoadError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfilePostLoadSuccess extends ProfilePostLoadResponse {
  ProfilePostLoadSuccess({
    required this.cursor,
  });

  final String? cursor;

  @override
  List<Object?> get props => [cursor];
}

// used with user profile friends page for infinite loading
class ProfileFriendLoadResponse extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileFriendLoadError extends ProfileFriendLoadResponse {
  ProfileFriendLoadError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileFriendLoadSuccess extends ProfileFriendLoadResponse {
  ProfileFriendLoadSuccess({
    required this.cursor,
  });

  final String? cursor;

  @override
  List<Object?> get props => [cursor];
}
