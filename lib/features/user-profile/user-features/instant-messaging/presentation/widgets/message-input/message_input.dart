import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/helpers/notifications/notifications_helper.dart';
import 'package:doko_react/core/helpers/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/gif-picker/gif_picker.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_overlay/nice_overlay.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({
    super.key,
    required this.archiveUser,
  });

  final String archiveUser;

  void showError(String message, BuildContext context) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.error,
    );

    NiceOverlay.showToast(toast);
  }

  void showNormal(String message, BuildContext context) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.normal,
    );

    NiceOverlay.showToast(toast);
  }

  void showSuccess(String message, BuildContext context) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.success,
    );

    NiceOverlay.showToast(toast);
  }

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final realTimeBloc = context.read<RealTimeBloc>();
    final client = context.read<WebsocketClientProvider>().client;

    return Row(
      children: [
        GifPicker(
          handleSelection: (String gifURL) {
            if (client == null || !client.isActive) {
              showError("You are not connected.", context);
              return;
            }

            ChatMessage message = ChatMessage(
              from: username,
              to: archiveUser,
              id: generateUniqueString(),
              subject: MessageSubject.mediaExternal,
              body: gifURL,
            );
            client.sendMessage(message);

            // fire bloc event
            realTimeBloc.add(RealTimeNewMessageEvent(
              message: message,
              username: username,
            ));
          },
          disabled: false,
        )
      ],
    );
  }
}
