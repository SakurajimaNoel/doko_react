import 'dart:async';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'instant_messaging_event.dart';
part 'instant_messaging_state.dart';

class InstantMessagingBloc
    extends Bloc<InstantMessagingEvent, InstantMessagingState> {
  InstantMessagingBloc() : super(InstantMessagingInitial()) {
    on<InstantMessagingNewMessageEvent>(_handleInstantMessagingNewMessageEvent);
    on<InstantMessagingTypingStatusEvent>(
        _handleInstantMessagingTypingStatusEvent);
    on<InstantMessagingEditMessageEvent>(
        _handleInstantMessagingEditMessageEvent);
    on<InstantMessagingDeleteMessageEvent>(
        _handleInstantMessagingDeleteMessageEvent);
  }

  FutureOr<void> _handleInstantMessagingNewMessageEvent(
      InstantMessagingNewMessageEvent event,
      Emitter<InstantMessagingState> emit) {
    UserGraph graph = UserGraph();
    ChatMessage message = event.message;
    graph.addNewMessage(message, event.username);

    /// when fetching inbox if inbox item already exists just resolve
    /// the messages only need to iterate 5 times at max

    /// emit states
    /// 1) to update inbox ordering
    /// 2) to update archive
    /// 3) to update inbox individual item to show latest message
    String archiveUser =
        getUsernameFromInboxItemKey(generateInboxKeyFromMessageParams(
      event.username,
      to: message.to,
      from: message.from,
    ));

    emit(InstantMessagingNewMessageState(
      id: message.id,
      archiveUser: archiveUser,
    ));
  }

  FutureOr<void> _handleInstantMessagingTypingStatusEvent(
      InstantMessagingTypingStatusEvent event,
      Emitter<InstantMessagingState> emit) async {
    emit(InstantMessagingTypingStatusState(
      archiveUser: event.status.from,
      typing: true,
    ));

    await Future.delayed(
      Duration(
        seconds: 4,
      ),
    );

    emit(InstantMessagingTypingStatusState(
      archiveUser: event.status.from,
      typing: false,
    ));
  }

  FutureOr<void> _handleInstantMessagingEditMessageEvent(
      InstantMessagingEditMessageEvent event,
      Emitter<InstantMessagingState> emit) async {
    UserGraph graph = UserGraph();
    graph.editMessage(event.message);

    String archiveUser =
        getUsernameFromInboxItemKey(generateInboxKeyFromMessageParams(
      event.username,
      to: event.message.to,
      from: event.message.from,
    ));
    emit(InstantMessagingEditMessageState(
      id: event.message.id,
      archiveUser: archiveUser,
    ));
  }

  FutureOr<void> _handleInstantMessagingDeleteMessageEvent(
      InstantMessagingDeleteMessageEvent event,
      Emitter<InstantMessagingState> emit) async {
    UserGraph graph = UserGraph();
    graph.deleteMessage(event.message);

    String archiveUser =
        getUsernameFromInboxItemKey(generateInboxKeyFromMessageParams(
      event.username,
      to: event.message.to,
      from: event.message.from,
    ));
    emit(InstantMessagingDeleteMessageState(
      id: event.message.id,
      archiveUser: archiveUser,
    ));
  }
}
