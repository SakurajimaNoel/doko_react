part of 'user_bloc.dart';

@immutable
sealed class UserEvent {}

final class UserInitEvent extends UserEvent {}

final class UserAuthenticatedEvent extends UserEvent {}

final class UserSignOutEvent extends UserEvent {}

final class UserProfileCompleteEvent extends UserEvent {}
