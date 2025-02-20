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

class ProfileTimelineLoadResponse extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileTimelineLoadError extends ProfileTimelineLoadResponse {
  ProfileTimelineLoadError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileTimelineLoadSuccess extends ProfileTimelineLoadResponse {
  ProfileTimelineLoadSuccess({
    required this.cursor,
  });

  final String? cursor;

  @override
  List<Object?> get props => [cursor];
}

// used with user profile friends page for infinite loading
class ProfileNodeLoadResponse extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileNodeLoadError extends ProfileNodeLoadResponse {
  ProfileNodeLoadError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileNodeLoadSuccess extends ProfileNodeLoadResponse {
  ProfileNodeLoadSuccess({
    required this.cursor,
  });

  final String? cursor;

  @override
  List<Object?> get props => [cursor];
}

// search results
final class ProfileUserSearchLoadingState extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileUserSearchErrorState extends ProfileState {
  ProfileUserSearchErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileUserSearchSuccessState extends ProfileState {
  ProfileUserSearchSuccessState({
    required this.searchResults,
  });

  final List<String> searchResults;

  @override
  List<Object?> get props => [searchResults];
}

// pending req more success state
class PendingRequestLoadResponse extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class PendingRequestLoadSuccessState extends PendingRequestLoadResponse {
  PendingRequestLoadSuccessState({
    required this.cursor,
  });

  final String? cursor;

  @override
  List<Object?> get props => [cursor];
}

final class PendingRequestLoadError extends PendingRequestLoadResponse {
  PendingRequestLoadError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

// comment search state
final class CommentSearchState extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class CommentSearchLoading extends CommentSearchState {
  @override
  List<Object?> get props => [];
}

final class CommentSearchSuccessState extends CommentSearchState {
  CommentSearchSuccessState({
    required this.searchResults,
    required this.query,
  });

  final String query;
  final List<String> searchResults;

  @override
  List<Object?> get props => [searchResults, query];
}

final class CommentSearchErrorState extends ProfileState {
  CommentSearchErrorState({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}
