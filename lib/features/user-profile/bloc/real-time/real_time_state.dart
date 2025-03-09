part of 'real_time_bloc.dart';

sealed class RealTimeState extends Equatable {
  const RealTimeState();
}

final class RealTimeInitial extends RealTimeState {
  @override
  List<Object> get props => [];
}

/// state used with user inbox icon in home page
final class RealTimeUserInboxUpdateState extends RealTimeState {
  RealTimeUserInboxUpdateState({
    this.archiveUser,
  }) : now = DateTime.now();

  final DateTime now;
  final String? archiveUser;

  @override
  List<Object?> get props => [now, archiveUser];
}

final class RealTimeNewMessageState extends RealTimeUserInboxUpdateState {
  RealTimeNewMessageState({
    required this.id,
    required super.archiveUser,
  });

  final String id;

  @override
  List<Object?> get props => [id];
}

final class RealTimeTypingStatusState extends RealTimeState {
  RealTimeTypingStatusState({
    required this.archiveUser,
    required this.typing,
  }) : statusAt = DateTime.now();

  final String archiveUser;
  final bool typing;
  final DateTime statusAt;

  @override
  List<Object?> get props => [archiveUser, statusAt, typing];
}

final class RealTimeEditMessageState extends RealTimeUserInboxUpdateState {
  RealTimeEditMessageState({
    required this.id,
    required super.archiveUser,
  });

  final String id;

  @override
  List<Object?> get props => [id];
}

final class RealTimeDeleteMessageState extends RealTimeUserInboxUpdateState {
  RealTimeDeleteMessageState({
    required this.id,
    required super.archiveUser,
  });

  final List<String> id;

  @override
  List<Object?> get props => [id.toString()];
}

final class RealTimeUserPresenceState extends RealTimeState {
  const RealTimeUserPresenceState({
    required this.online,
    required this.username,
  });

  final bool online;
  final String username;

  @override
  List<Object?> get props => [online, username];
}
