import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/throttle/throttle.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/gif-picker/gif_picker.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/provider/archive_message_provider.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/typing-status/typing_status_widget_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  late final FocusNode focusNode =
      context.read<ArchiveMessageProvider>().focusNode;
  final Throttle throttle = Throttle(Constants.typingStatusEventDuration);
  late final Client? client;
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  bool showMoreOptions = false;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);
    controller.addListener(handleTextChange);
    client = context.read<WebsocketClientProvider>().client;
  }

  void handleTextChange() {
    if (client == null || !client!.isActive) {
      return;
    }
    TypingStatus sendStatus = TypingStatus(
      from: username,
      to: widget.archiveUser,
    );

    throttle(() {
      client!.sendPayload(sendStatus);
    });
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
    controller.removeListener(handleTextChange);
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final realTimeBloc = context.read<RealTimeBloc>();
    final client = context.read<WebsocketClientProvider>().client;

    Widget gifPicker = GifPicker(
      handleSelection: (String gifURL) async {
        ChatMessage message = ChatMessage(
          from: username,
          to: widget.archiveUser,
          id: generateUniqueString(),
          subject: MessageSubject.mediaExternal,
          body: gifURL,
          sendAt: DateTime.now(),
        );
        bool result = await client?.sendPayload(message) ?? false;

        if (result) {
          // fire bloc event
          realTimeBloc.add(RealTimeNewMessageEvent(
            message: message,
            username: username,
          ));
        } else {
          showError(Constants.websocketNotConnectedError);
        }
      },
      disabled: false,
    );

    return Column(
      spacing: Constants.gap * 0.5,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          child: TypingStatusWidgetWrapper(
            username: widget.archiveUser,
          ),
        ),
        Container(
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
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          Constants.messageLimit,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        ),
                      ],
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
                      onPressed: () async {
                        final messageBody = controller.text.trim();
                        if (messageBody.isEmpty) return;

                        ChatMessage message = ChatMessage(
                          from: username,
                          to: widget.archiveUser,
                          id: generateUniqueString(),
                          subject: MessageSubject.text,
                          body: messageBody,
                          sendAt: DateTime.now(),
                        );
                        bool result =
                            await client?.sendPayload(message) ?? false;

                        HapticFeedback.vibrate();

                        if (result) {
                          // fire bloc event
                          realTimeBloc.add(RealTimeNewMessageEvent(
                            message: message,
                            username: username,
                          ));

                          controller.clear();
                          setState(() {});
                        } else {
                          showError(Constants.websocketNotConnectedError);
                        }
                      },
                      child: const Text("Send"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
