import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart' hide Emitter;
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/graphql/mutations/message_archive_mutations.dart';
import 'package:doko_react/core/global/api/api.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/bloc/instant_messaging_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'real_time_event.dart';
part 'real_time_state.dart';

class RealTimeBloc extends Bloc<RealTimeEvent, RealTimeState> {
  UserGraph graph = UserGraph();
  RealTimeBloc() : super(RealTimeInitial()) {
    on<RealTimeNewMessageEvent>(_handleRealTimeNewMessageEvent);
    on<RealTimeTypingStatusEvent>(_handleRealTimeTypingStatusEvent);
    on<RealTimeTypingStatusEndEvent>(_handleRealTimeTypingStatusEndEvent);
    on<RealTimeEditMessageEvent>(_handleRealTimeEditMessageEvent);
    on<RealTimeDeleteMessageEvent>(_handleRealTimeDeleteMessageEvent);
    on<RealTimeUserPresenceEvent>((event, emit) {
      emit(RealTimeUserPresenceState(
        online: event.payload.online,
        username: event.payload.user,
      ));
    });
    on<RealTimeInboxUpdateEvent>((event, emit) {
      emit(RealTimeUserInboxUpdateState());
    });
    on<RealTimeMarkInboxAsReadEvent>(_handleRealTimeMarkInboxAsReadEvent);
    on<RealTimeInboxGetEvent>(
      _handleRealTimeInboxGetEvent,
      transformer: droppable(),
    );
  }

  FutureOr<void> _handleRealTimeMarkInboxAsReadEvent(
      RealTimeMarkInboxAsReadEvent event, Emitter<RealTimeState> emit) async {
    String inboxKey = generateInboxItemKey(event.archive);
    final inboxItem = graph.getValueByKey(inboxKey);

    bool initialStatus = true;
    if (inboxItem is InboxItemEntity) {
      initialStatus = inboxItem.unread;
      inboxItem.updateUnread(false);
    }

    if (initialStatus) {
      // ignoring error here
      await mutate(
        GraphQLRequest(
          document: MessageArchiveMutations.markInboxAsRead(),
          variables: MessageArchiveMutations.markInboxAsReadVariables(
            inboxUser: event.archive,
            user: event.currentUser,
          ),
        ),
      );
    }
    emit(RealTimeUserInboxUpdateState());

    /// also send read event to websocket server to handle it
    /// when handling everything from backend
  }

  FutureOr<void> _handleRealTimeNewMessageEvent(
      RealTimeNewMessageEvent event, Emitter<RealTimeState> emit) {
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

    add(RealTimeTypingStatusEndEvent(
      username: archiveUser,
    ));

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
    graph.editMessage(event.message, event.username);

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

    graph.deleteMessage(event.message, event.username);

    emit(RealTimeDeleteMessageState(
      id: event.message.id,
      archiveUser: archiveUser,
    ));
  }

  FutureOr<void> _handleRealTimeInboxGetEvent(
      RealTimeInboxGetEvent event, Emitter<RealTimeState> emit) async {
    final instantMessagingBloc = serviceLocator<InstantMessagingBloc>();

    Future imBloc = instantMessagingBloc.stream.first;
    instantMessagingBloc.add(InstantMessagingGetUserInbox(
      details: event.details,
    ));

    final imState = await imBloc;
    if (imState is InstantMessagingErrorState) {
      showError(imState.message);
    }

    add(RealTimeInboxUpdateEvent());
  }
}
