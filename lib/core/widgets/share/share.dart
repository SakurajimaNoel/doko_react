import 'package:doki_websocket_client/doki_websocket_client.dart';
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
import 'package:share_plus/share_plus.dart' as share_external;

class Share extends StatelessWidget {
  const Share({
    super.key,
  });

  static void share({
    required BuildContext context,
    required MessageSubject subject,
    required String nodeIdentifier,
  }) {
    final instantMessagingBloc = serviceLocator<InstantMessagingBloc>();

    UserQuickActionWidget.showUserModal(
      onlyFriends: false,
      context: context,
      onDone: (selectedUsers) async {
        int selectedLength = selectedUsers.length;
        final username =
            (context.read<UserBloc>().state as UserCompleteState).username;

        final client = context.read<WebsocketClientProvider>().client;
        final realTimeBloc = context.read<RealTimeBloc>();
        final List<ChatMessage> messages = [];

        for (String userToSend in selectedUsers) {
          ChatMessage message = ChatMessage(
            from: username,
            to: userToSend,
            id: generateTimeBasedUniqueString(),
            subject: subject,
            body: nodeIdentifier,
            sendAt: DateTime.now(),
          );
          messages.add(message);
        }

        Future imBloc = instantMessagingBloc.stream.first;
        instantMessagingBloc.add(InstantMessagingSendMultipleMessageEvent(
          messages: messages,
          client: client,
        ));

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

        String successMessage;
        String messageEnd =
            "with $selectedLength user${selectedLength > 1 ? "s" : ""}";
        switch (subject) {
          case MessageSubject.dokiUser:
            successMessage = "Shared @$nodeIdentifier profile $messageEnd";
          case MessageSubject.dokiPost:
            successMessage = "Shared post $messageEnd";
          case MessageSubject.dokiPage:
            successMessage = "Shared page $messageEnd";
          case MessageSubject.dokiDiscussion:
            successMessage = "Shared discussion $messageEnd";
          case MessageSubject.dokiPolls:
            successMessage = "Shared polls $messageEnd";
          default:
            successMessage = "";
        }

        if (successMessage.isNotEmpty) {
          showSuccess(successMessage);
        }
        return true;
      },
      limit: Constants.shareLimit,
      limitReachedLabel:
          "You can send up to ${Constants.shareLimit} users at a time.",
      actionLabel: "Send",
      whenEmptySelection: FilledButton.tonal(
        onPressed: () {
          final String baseUrl = "https://doki.co.in";
          String url;
          String supportingText;

          switch (subject) {
            case MessageSubject.dokiUser:
              url = "$baseUrl/user/$nodeIdentifier";
              supportingText = "Check @$nodeIdentifier profile on doki.";
            case MessageSubject.dokiPost:
              url = "$baseUrl/post/$nodeIdentifier";
              supportingText = "Check this Post on doki.";
            case MessageSubject.dokiPage:
              url = "$baseUrl/page/$nodeIdentifier";
              supportingText = "Check this Page on doki.";
            case MessageSubject.dokiDiscussion:
              url = "$baseUrl/discussion/$nodeIdentifier";
              supportingText = "Check this Discussion on doki.";
            case MessageSubject.dokiPolls:
              url = "$baseUrl/poll/$nodeIdentifier";
              supportingText = "Check this Poll on doki.";
            default:
              url = "";
              supportingText = "";
          }

          if (url.isEmpty || supportingText.isEmpty) return;

          share_external.Share.share(
            url,
            subject: supportingText,
          );
        },
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            Constants.buttonWidth,
            Constants.buttonHeight,
          ),
        ),
        child: const Text("More share options."),
      ),
    );

    return;
  }

  @override
  Widget build(BuildContext context) {
    return const Text("Use static method \"share\" to allow sharing.");
  }
}
