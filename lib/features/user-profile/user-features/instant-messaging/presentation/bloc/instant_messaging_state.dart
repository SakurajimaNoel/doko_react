part of 'instant_messaging_bloc.dart';

sealed class InstantMessagingState extends Equatable {
  const InstantMessagingState();
}

final class InstantMessagingInitial extends InstantMessagingState {
  @override
  List<Object> get props => [];
}

final class InstantMessagingSuccessState extends InstantMessagingState {
  InstantMessagingSuccessState() : now = DateTime.now();

  final DateTime now;

  @override
  List<Object> get props => [now];
}

final class InstantMessagingErrorState extends InstantMessagingState {
  InstantMessagingErrorState({
    required this.message,
  }) : now = DateTime.now();

  final DateTime now;
  final String message;

  @override
  List<Object> get props => [now, message];
}
