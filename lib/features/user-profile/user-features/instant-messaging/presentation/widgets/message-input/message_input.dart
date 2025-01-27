import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/notifications/notifications_helper.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/gif-picker/gif_picker.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.archiveUser,
  });

  final String archiveUser;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool showMoreOptions = false;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      if (!showMoreOptions) {
        setState(() {
          showMoreOptions = true;
        });
      }
    } else {
      if (showMoreOptions) {
        setState(() {
          showMoreOptions = false;
        });
      }
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChange);
    focusNode.dispose();

    controller.dispose();

    super.dispose();
  }

  void showError(String message) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.error,
    );

    showToast(toast);
  }

  void showNormal(String message) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.normal,
    );

    showToast(toast);
  }

  void showSuccess(String message) {
    final toast = createNewToast(
      context,
      message: message,
      type: ToastType.success,
    );

    showToast(toast);
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final realTimeBloc = context.read<RealTimeBloc>();
    final client = context.read<WebsocketClientProvider>().client;

    Widget gifPicker = GifPicker(
      handleSelection: (String gifURL) {
        if (client == null || !client.isActive) {
          showError("You are not connected.");
          return;
        }

        ChatMessage message = ChatMessage(
          from: username,
          to: widget.archiveUser,
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
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (focusNode.hasFocus) {
          FocusScope.of(context).unfocus();
          return;
        }

        context.pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Constants.padding * 0.125,
          horizontal: Constants.padding,
        ),
        decoration: BoxDecoration(
          color: currTheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              width: 1.5,
              color: currTheme.outline,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Constants.gap * 0.25,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Constants.gap * 0.5,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Type your message here...",
                    ),
                  ),
                ),
                if (!showMoreOptions) gifPicker,
              ],
            ),
            if (showMoreOptions)
              Row(
                spacing: Constants.gap * 0.5,
                children: [
                  gifPicker,
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      final messageBody = controller.text;
                      if (messageBody.isEmpty) return;

                      if (client == null || !client.isActive) {
                        showError("You are offline.");
                        return;
                      }

                      ChatMessage message = ChatMessage(
                        from: username,
                        to: widget.archiveUser,
                        id: generateUniqueString(),
                        subject: MessageSubject.text,
                        body: messageBody,
                      );
                      client.sendMessage(message);

                      Vibration.vibrate(
                        pattern: [0, 100],
                        intensities: [0, 64],
                      );
                      // fire bloc event
                      realTimeBloc.add(RealTimeNewMessageEvent(
                        message: message,
                        username: username,
                      ));

                      controller.clear();
                      setState(() {});
                    },
                    child: Text("Send"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
