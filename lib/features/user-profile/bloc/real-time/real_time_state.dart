part of 'real_time_bloc.dart';

sealed class RealTimeState extends Equatable {
  const RealTimeState();
}

final class RealTimeInitial extends RealTimeState {
  @override
  List<Object> get props => [];
}

final class RealTimeNewMessageState extends RealTimeState {
  const RealTimeNewMessageState({
    required this.id,
    required this.archiveUser,
  });

  final String id;
  final String archiveUser;

  @override
  List<Object?> get props => [id, archiveUser];
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

final class RealTimeEditMessageState extends RealTimeState {
  RealTimeEditMessageState({
    required this.id,
    required this.archiveUser,
  });

  final String id;
  final String archiveUser;
  final DateTime editedAt = DateTime.now();

  @override
  List<Object?> get props => [id, editedAt, archiveUser];
}

final class RealTimeDeleteMessageState extends RealTimeState {
  RealTimeDeleteMessageState({
    required this.id,
    required this.archiveUser,
  });

  final List<String> id;
  final String archiveUser;
  final DateTime editedAt = DateTime.now();

  @override
  List<Object?> get props => [id.toString(), editedAt, archiveUser];
}
