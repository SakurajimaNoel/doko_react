import 'dart:async';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'instant_messaging_event.dart';
part 'instant_messaging_state.dart';

class InstantMessagingBloc
    extends Bloc<InstantMessagingEvent, InstantMessagingState> {
  InstantMessagingBloc() : super(InstantMessagingInitial()) {
    on<InstantMessagingSendNewMessageEvent>(
        _handleInstantMessagingSendNewMessageEvent);
    on<InstantMessagingSendNewMessageToMultipleUserEvent>(
        _handleInstantMessagingSendNewMessageToMultipleUserEvent);
    on<InstantMessagingEditMessageEvent>(
        _handleInstantMessagingEditMessageEvent);
    on<InstantMessagingDeleteMessageEvent>(
        _handleInstantMessagingDeleteMessageEvent);
    on<InstantMessagingDeleteMultipleMessageEvent>(
        _handleInstantMessagingDeleteMultipleMessageEvent);
  }

  FutureOr<void> _handleInstantMessagingSendNewMessageEvent(
      InstantMessagingSendNewMessageEvent event,
      Emitter<InstantMessagingState> emit) async {}

  FutureOr<void> _handleInstantMessagingSendNewMessageToMultipleUserEvent(
      InstantMessagingSendNewMessageToMultipleUserEvent event,
      Emitter<InstantMessagingState> emit) async {
    try {
      // send message to clients
      final messages = event.messages;
      final client = event.client;
      for (var message in messages) {
        bool result = await client?.sendPayload(message) ?? false;
        if (result) {
          /// calling another bloc from inside of another bloc is not recommended
          event.realTimeBloc.add(RealTimeNewMessageEvent(
            message: message,
            username: message.from, // this will by current user's username
            client: client,
          ));
        } else {
          throw const ApplicationException(
            reason: Constants.websocketNotConnectedError,
          );
        }
      }

      emit(InstantMessagingSuccessState());
    } catch (_) {
      emit(InstantMessagingErrorState(
        message: Constants.websocketNotConnectedError,
      ));
    }
  }

  FutureOr<void> _handleInstantMessagingEditMessageEvent(
      InstantMessagingEditMessageEvent event,
      Emitter<InstantMessagingState> emit) async {}

  FutureOr<void> _handleInstantMessagingDeleteMessageEvent(
      InstantMessagingDeleteMessageEvent event,
      Emitter<InstantMessagingState> emit) async {}

  FutureOr<void> _handleInstantMessagingDeleteMultipleMessageEvent(
      InstantMessagingDeleteMultipleMessageEvent event,
      Emitter<InstantMessagingState> emit) async {}
}
