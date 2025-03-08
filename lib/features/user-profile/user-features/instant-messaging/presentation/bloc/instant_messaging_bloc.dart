import 'dart:async';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
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
  }

  /// todo handle updating of user inbox

  FutureOr<void> _handleInstantMessagingSendNewMessageEvent(
      InstantMessagingSendNewMessageEvent event,
      Emitter<InstantMessagingState> emit) async {
    try {
      final message = event.message;
      final client = event.client;

      bool result = await client?.sendPayload(message) ?? false;
      if (!result) {
        throw const ApplicationException(
          reason: Constants.websocketNotConnectedError,
        );
      }
      HapticFeedback.vibrate();
      emit(InstantMessagingSendMessageSuccessState(
        message: event.message,
      ));
    } catch (_) {
      emit(InstantMessagingSendMessageErrorState(
        message: Constants.websocketNotConnectedError,
      ));
    }
  }

  FutureOr<void> _handleInstantMessagingSendNewMessageToMultipleUserEvent(
      InstantMessagingSendNewMessageToMultipleUserEvent event,
      Emitter<InstantMessagingState> emit) async {
    List<ChatMessage> messagesSent = [];
    try {
      // send message to clients
      final messages = event.messages;
      final client = event.client;
      for (var message in messages) {
        bool result = await client?.sendPayload(message) ?? false;
        if (!result) {
          throw const ApplicationException(
            reason: Constants.websocketNotConnectedError,
          );
        }

        messagesSent.add(message);
      }

      emit(InstantMessagingSendMessageToMultipleUserSuccessState(
        messages: messages,
      ));
    } catch (_) {
      emit(InstantMessagingSendMessageToMultipleUserErrorState(
        message: Constants.websocketNotConnectedError,
        messagesSent: messagesSent,
      ));
    }
  }

  FutureOr<void> _handleInstantMessagingEditMessageEvent(
      InstantMessagingEditMessageEvent event,
      Emitter<InstantMessagingState> emit) async {
    try {
      bool result = await event.client?.sendPayload(event.message) ?? false;
      if (!result) {
        throw const ApplicationException(
          reason: Constants.websocketNotConnectedError,
        );
      }

      emit(InstantMessagingEditMessageSuccessState(
        message: event.message,
      ));
    } catch (_) {
      emit(InstantMessagingEditMessageErrorState(
        message: Constants.websocketNotConnectedError,
      ));
    }
  }

  FutureOr<void> _handleInstantMessagingDeleteMessageEvent(
      InstantMessagingDeleteMessageEvent event,
      Emitter<InstantMessagingState> emit) async {
    try {
      bool result = await event.client?.sendPayload(event.message) ?? false;
      if (!result) {
        throw const ApplicationException(
          reason: Constants.websocketNotConnectedError,
        );
      }

      emit(InstantMessagingDeleteMessageSuccessState(
        message: event.message,
      ));
    } catch (_) {
      emit(InstantMessagingDeleteMessageErrorState(
        message: Constants.websocketNotConnectedError,
        multiple: event.message.id.length > 1,
      ));
    }
  }
}
