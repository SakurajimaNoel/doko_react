part of 'user_action_bloc.dart';

@immutable
sealed class UserActionEvent {}

final class TrialEvent extends UserActionEvent {}
