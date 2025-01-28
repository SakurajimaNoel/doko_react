import 'dart:async';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'real_time_event.dart';
part 'real_time_state.dart';

class RealTimeBloc extends Bloc<RealTimeEvent, RealTimeState> {
  RealTimeBloc() : super(RealTimeInitial()) {
    on<RealTimeNewMessageEvent>(_handleRealTimeNewMessageEvent);
    on<RealTimeTypingStatusEvent>(_handleRealTimeTypingStatusEvent);
    on<RealTimeTypingStatusEndEvent>(_handleRealTimeTypingStatusEndEvent);
    on<RealTimeEditMessageEvent>(_handleRealTimeEditMessageEvent);
    on<RealTimeDeleteMessageEvent>(_handleRealTimeDeleteMessageEvent);
  }

  FutureOr<void> _handleRealTimeNewMessageEvent(
      RealTimeNewMessageEvent event, Emitter<RealTimeState> emit) {
    UserGraph graph = UserGraph();
    ChatMessage message = event.message;
    graph.addNewMessage(message, event.username);

    /// when fetching inbox if inbox item already exists just resolve
    /// the messages only need to iterate 5 times at max

    /// emit states
    /// 1) to update inbox ordering
    /// 2) to update archive
    /// 3) to update inbox individual item to show latest message
    String archiveUser = getUsernameFromMessageParams(
      event.username,
      to: message.to,
      from: message.from,
    );

    emit(RealTimeNewMessageState(
      id: message.id,
      archiveUser: archiveUser,
    ));
  }

  FutureOr<void> _handleRealTimeTypingStatusEvent(
      RealTimeTypingStatusEvent event, Emitter<RealTimeState> emit) async {
    emit(RealTimeTypingStatusState(
      archiveUser: event.status.from,
      typing: true,
    ));

    // await Future.delayed(
    //   Duration(
    //     seconds: 4,
    //   ),
    // );
    //
    // emit(RealTimeTypingStatusState(
    //   archiveUser: event.status.from,
    //   typing: false,
    // ));
  }

  FutureOr<void> _handleRealTimeTypingStatusEndEvent(
      RealTimeTypingStatusEndEvent event, Emitter<RealTimeState> emit) async {
    emit(RealTimeTypingStatusState(
      archiveUser: event.username,
      typing: false,
    ));
  }

  FutureOr<void> _handleRealTimeEditMessageEvent(
      RealTimeEditMessageEvent event, Emitter<RealTimeState> emit) async {
    UserGraph graph = UserGraph();
    graph.editMessage(event.message);

    String archiveUser = getUsernameFromMessageParams(
      event.username,
      to: event.message.to,
      from: event.message.from,
    );
    emit(RealTimeEditMessageState(
      id: event.message.id,
      archiveUser: archiveUser,
    ));
  }

  FutureOr<void> _handleRealTimeDeleteMessageEvent(
      RealTimeDeleteMessageEvent event, Emitter<RealTimeState> emit) async {
    UserGraph graph = UserGraph();

    String archiveUser = getUsernameFromMessageParams(
      event.username,
      to: event.message.to,
      from: event.message.from,
    );
    graph.deleteMessage(event.message, archiveUser);

    emit(RealTimeDeleteMessageState(
      id: event.message.id,
      archiveUser: archiveUser,
    ));
  }
}
