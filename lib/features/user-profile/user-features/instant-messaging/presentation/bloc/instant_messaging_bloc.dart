import 'dart:async';
import 'dart:collection';

import 'package:amplify_api/amplify_api.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/graphql/mutations/message_archive_mutations.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/api/api.dart';
import 'package:doko_react/core/utils/instant-messaging/message_preview.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/archive_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/domain/use-case/archive-use-case/archive_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/domain/use-case/inbox-use-case/inbox_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/archive-query-input/archive_query_input.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-mutation-input/inbox_mutation_input.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'instant_messaging_event.dart';
part 'instant_messaging_state.dart';

class InstantMessagingBloc
    extends Bloc<InstantMessagingEvent, InstantMessagingState> {
  final ArchiveUseCase archiveUseCase;
  final InboxUseCase inboxUseCase;

  final UserGraph graph = UserGraph();

  InstantMessagingBloc({
    required this.archiveUseCase,
    required this.inboxUseCase,
  }) : super(InstantMessagingInitial()) {
    on<InstantMessagingSendNewMessageEvent>(
        _handleInstantMessagingSendNewMessageEvent);
    on<InstantMessagingSendMultipleMessageEvent>(
        _handleInstantMessagingSendMultipleMessageEvent);
    on<InstantMessagingEditMessageEvent>(
        _handleInstantMessagingEditMessageEvent);
    on<InstantMessagingDeleteInboxEntry>(
        _handleInstantMessagingDeleteInboxEntry);
    on<InstantMessagingDeleteMessageEvent>(
        _handleInstantMessagingDeleteMessageEvent);
    on<InstantMessagingGetUserInbox>(
      _handleInstantMessagingGetUserInbox,
      transformer: droppable(),
    );
    on<InstantMessagingGetUserArchive>(_handleInstantMessagingGetUserArchive);
  }

  FutureOr<void> _handleInstantMessagingGetUserInbox(
      InstantMessagingGetUserInbox event,
      Emitter<InstantMessagingState> emit) async {
    try {
      String inboxKey = generateInboxKey();
      var inbox = graph.getValueByKey(inboxKey);
      if (inbox is InboxEntity &&
          event.details.cursor.isEmpty &&
          inbox.isNotEmpty) {
        emit(InstantMessagingSuccessState());
        return;
      }

      await inboxUseCase(event.details);
      emit(InstantMessagingSuccessState());
    } catch (e) {
      String reason = Constants.errorMessage;
      if (e is ApplicationException) reason = e.reason;

      emit(InstantMessagingErrorState(
        message: reason,
      ));
    }
  }

  FutureOr<void> _handleInstantMessagingGetUserArchive(
      InstantMessagingGetUserArchive event,
      Emitter<InstantMessagingState> emit) async {
    try {
      String archiveKey = generateArchiveKey(event.details.username);
      var archive = graph.getValueByKey(archiveKey);
      if (archive is ArchiveEntity &&
          event.details.cursor.isEmpty &&
          archive.isNotEmpty) {
        emit(InstantMessagingSuccessState());
        return;
      }

      await archiveUseCase(event.details);
      emit(InstantMessagingSuccessState());
    } catch (e) {
      String reason = Constants.errorMessage;
      if (e is ApplicationException) reason = e.reason;

      emit(InstantMessagingErrorState(
        message: reason,
      ));
    }
  }

  Future<void> _addMessageToArchive(List<ChatMessage> messages) async {
    for (int i = 0; i < messages.length; i += Constants.batchSize) {
      final batch = messages.sublist(
        i,
        i + Constants.batchSize > messages.length
            ? messages.length
            : i + Constants.batchSize,
      );
      await mutate(GraphQLRequest(
        document: MessageArchiveMutations.addMessageToArchive(),
        variables: MessageArchiveMutations.addMessageToArchiveVariables(
          messages: batch,
        ),
      ));
    }
  }

  Future<void> _editMessageInArchive(EditMessage message) async {
    await mutate(GraphQLRequest(
      document: MessageArchiveMutations.editMessageInArchive(),
      variables: MessageArchiveMutations.editMessageInArchiveVariables(
        message,
      ),
    ));
  }

  Future<void> _deleteMessageInArchive(DeleteMessage message) async {
    await mutate(GraphQLRequest(
      document: MessageArchiveMutations.deleteMessageInArchive(),
      variables: MessageArchiveMutations.deleteMessageInArchiveVariables(
        message,
      ),
    ));
  }

  Future<void> _updateInbox(List<InboxMutationInput> details) async {
    for (int i = 0; i < details.length; i += Constants.batchSize) {
      final batch = details.sublist(
        i,
        i + Constants.batchSize > details.length
            ? details.length
            : i + Constants.batchSize,
      );
      await mutate(GraphQLRequest(
        document: MessageArchiveMutations.updateUserInbox(),
        variables: MessageArchiveMutations.updateUserInboxVariables(
          inboxDetails: batch,
        ),
      ));
    }
  }

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

      final myInbox = InboxMutationInput(
        user: event.username,
        inboxUser: message.to,
        displayText: messagePreview(message, event.username),
        unread: false,
      );
      final remoteInbox = InboxMutationInput(
        user: message.to,
        inboxUser: event.username,
        displayText: messagePreview(message, message.to),
        unread: true,
      );

      List<InboxMutationInput> inboxItems = [];
      inboxItems.add(myInbox);
      if (message.from != message.to) {
        inboxItems.add(remoteInbox);
      }

      await Future.wait([
        _updateInbox(inboxItems),
        _addMessageToArchive([message]),
      ]);
    } catch (_) {
      emit(InstantMessagingSendMessageErrorState(
        message: Constants.websocketNotConnectedError,
      ));
    }
  }

  Future<void> _updateInboxForMultipleMessages(
      List<ChatMessage> messages, String username) async {
    Set<String> seen = HashSet();
    List<ChatMessage> uniqueMessages = [];

    for (int i = messages.length - 1; i >= 0; i--) {
      if (seen.add(messages[i].to)) {
        uniqueMessages.add(messages[i]);
      }
    }

    List<InboxMutationInput> inboxItems = [];
    for (var message in uniqueMessages) {
      inboxItems.addAll([
        InboxMutationInput(
          user: username,
          inboxUser: message.to,
          displayText: messagePreview(message, username),
          unread: false,
        ),
        InboxMutationInput(
          user: message.to,
          inboxUser: username,
          displayText: messagePreview(message, message.to),
          unread: true,
        )
      ]);
    }

    await _updateInbox(inboxItems);
  }

  FutureOr<void> _handleInstantMessagingSendMultipleMessageEvent(
      InstantMessagingSendMultipleMessageEvent event,
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

      await Future.wait([
        _updateInboxForMultipleMessages(messages, event.username),
        _addMessageToArchive(messages),
      ]);
    } catch (_) {
      emit(InstantMessagingSendMessageToMultipleUserErrorState(
        message: Constants.websocketNotConnectedError,
        messagesSent: messagesSent,
      ));
      await Future.wait([
        _updateInboxForMultipleMessages(messagesSent, event.username),
        _addMessageToArchive(messagesSent),
      ]);
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

      final myInbox = InboxMutationInput(
        user: event.username,
        inboxUser: event.message.to,
        displayText: selfEditText,
        unread: false,
      );
      final remoteInbox = InboxMutationInput(
        user: event.message.to,
        inboxUser: event.username,
        displayText: remoteEditText(event.username),
        unread: true,
      );

      List<InboxMutationInput> inboxItems = [];
      inboxItems.add(myInbox);
      if (event.message.from != event.message.to) {
        inboxItems.add(remoteInbox);
      }

      await Future.wait(
          [_updateInbox(inboxItems), _editMessageInArchive(event.message)]);
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

      final myInbox = InboxMutationInput(
        user: event.username,
        inboxUser: event.message.to,
        displayText: selfDeleteText,
        unread: false,
      );
      final remoteInbox = InboxMutationInput(
        user: event.message.to,
        inboxUser: event.username,
        displayText: remoteDeleteText(event.username),
        unread: true,
      );
      List<InboxMutationInput> inboxItems = [];
      inboxItems.add(myInbox);
      if (event.message.from != event.message.to) {
        inboxItems.add(remoteInbox);
      }

      await Future.wait([
        _updateInbox(inboxItems),
        _deleteMessageInArchive(event.message),
      ]);
    } catch (_) {
      emit(InstantMessagingDeleteMessageErrorState(
        message: Constants.websocketNotConnectedError,
        // multiple: event.message.id.length > 1,
      ));
    }
  }

  FutureOr<void> _handleInstantMessagingDeleteInboxEntry(
      InstantMessagingDeleteInboxEntry event,
      Emitter<InstantMessagingState> emit) async {
    var res = await mutate(GraphQLRequest(
      document: MessageArchiveMutations.deleteInboxEntry(),
      variables: MessageArchiveMutations.deleteInboxEntryVariables(
        user: event.user,
        inboxUser: event.inboxUser,
      ),
    ));

    if (res.hasErrors) {
      emit(InstantMessagingErrorState(
        message: Constants.errorMessage,
      ));
    } else {
      graph.removeEntryFromInbox(
        inboxUser: event.inboxUser,
      );
      emit(InstantMessagingSuccessState());
    }
  }
}
