import 'dart:async';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/user-quick-action-widget/user_quick_action_widget.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/bloc/instant_messaging_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MessageForward extends StatelessWidget {
  const MessageForward({
    super.key,
  });

  static void forward({
    required BuildContext context,
    required List<ChatMessage> messagesToForward,
  }) {
    final instantMessagingBloc = serviceLocator<InstantMessagingBloc>();
    messagesToForward.sort((a, b) => a.sendAt.compareTo(b.sendAt));

    UserQuickActionWidget.showUserModal(
      onlyFriends: false,
      context: context,
      onDone: (selectedUsers) async {
        int messagesLength = messagesToForward.length;
        final username =
            (context.read<UserBloc>().state as UserCompleteState).username;

        final client = context.read<WebsocketClientProvider>().client;
        final realTimeBloc = context.read<RealTimeBloc>();
        final List<ChatMessage> messages = [];

        for (String userToSend in selectedUsers) {
          for (var message in messagesToForward) {
            var forwardMessage = message.copyWith(
              from: username,
              to: userToSend,
              sendAt: DateTime.now(),
              forwarded: true,
              id: generateTimeBasedUniqueString(),
              replyOn: null,
            );
            messages.add(forwardMessage);
          }
        }

        Future imBloc = instantMessagingBloc.stream.first;
        instantMessagingBloc.add(InstantMessagingSendMultipleMessageEvent(
          messages: messages,
          client: client,
        ));

        final pushReplacementNamed = context.pushReplacementNamed;
        final state = await imBloc;

        if (state is InstantMessagingSendMessageToMultipleUserErrorState) {
          showError(state.message);
          // update inbox for sent messages
          for (var message in state.messagesSent) {
            realTimeBloc.add(RealTimeNewMessageEvent(
              message: message,
              username: username,
            ));
          }
          return false;
        }

        if (state is! InstantMessagingSendMessageToMultipleUserSuccessState) {
          return false;
        }

        for (var message in state.messages) {
          realTimeBloc.add(RealTimeNewMessageEvent(
            message: message,
            username: username,
          ));
        }

        String successMessage =
            "$messagesLength message${messagesLength > 1 ? "s" : ""} forwarded.";

        if (successMessage.isNotEmpty) {
          showSuccess(successMessage);
        }

        pushReplacementNamed(
          RouterConstants.messageArchive,
          pathParameters: {
            "username": selectedUsers.last,
          },
        );

        return false;
      },
      limit: Constants.shareLimit,
      limitReachedLabel:
          "You can forward up to ${Constants.shareLimit} users at a time.",
      actionLabel: "Forward",
    );

    return;
  }

  @override
  Widget build(BuildContext context) {
    return const Text("Use static method \"forward\" to allow forwarding.");
  }
}
