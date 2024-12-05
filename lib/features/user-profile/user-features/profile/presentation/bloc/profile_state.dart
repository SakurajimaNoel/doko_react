part of 'profile_bloc.dart';

@immutable
sealed class ProfileState extends Equatable {}

final class ProfileInitial extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileSuccess extends ProfileState {
  @override
  List<Object?> get props => [];
}

final class ProfileError extends ProfileState {
  ProfileError({
    required this.message,
  });

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileEditSuccess extends ProfileState {
  @override
  List<Object?> get props => [];
}

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
