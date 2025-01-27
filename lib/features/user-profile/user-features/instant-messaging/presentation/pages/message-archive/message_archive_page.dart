import 'dart:collection';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/archive_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/archive-item/archive_item.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/message-input/message_input.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MessageArchivePage extends StatefulWidget {
  const MessageArchivePage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<MessageArchivePage> createState() => _MessageArchivePageState();
}

class _MessageArchivePageState extends State<MessageArchivePage> {
  Set<String> messagesSelected = HashSet();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void onSelect(String messageId) {
    setState(() {
      messagesSelected.add(messageId);
    });
  }

  bool isSelected(String messageId) {
    return messagesSelected.contains(messageId);
  }

  bool canDisplayMoreOptions() {
    return messagesSelected.isEmpty;
  }

  void deleteMessage(String messageId, bool everyone) {
    final client = context.read<WebsocketClientProvider>().client;

    if (client == null) {
      showError(context, "You are not connected.");
    }

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    DeleteMessage deleteMessage = DeleteMessage(
      from: username,
      to: widget.username,
      id: [messageId],
      everyone: everyone,
    );

    bool result = client!.deleteMessage(deleteMessage);
    if (result) {
      context.read<RealTimeBloc>().add(RealTimeDeleteMessageEvent(
            message: deleteMessage,
            username: username,
          ));
    } else {
      showError(context, "Failed to delete message.");
    }
  }

  void deleteSelected() {
    final client = context.read<WebsocketClientProvider>().client;

    if (client == null) {
      showError(context, "You are not connected.");
    }

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    DeleteMessage deleteMessage = DeleteMessage(
      from: username,
      to: widget.username,
      id: messagesSelected.toList(growable: false),
      everyone: false,
    );

    bool result = client!.deleteMessage(deleteMessage);
    if (result) {
      context.read<RealTimeBloc>().add(RealTimeDeleteMessageEvent(
            message: deleteMessage,
            username: username,
          ));
      messagesSelected.clear();
      setState(() {});
    } else {
      showError(
          context, "Failed to delete ${messagesSelected.length} messages.");
    }
  }

  Widget buildItem(BuildContext context, int index, List<String> messages) {
    bool showDate = false;

    /// show date will be true if current message and previous message are not on same day
    if (index == messages.length - 1) {
      showDate = true;
    } else {
      UserGraph graph = UserGraph();
      final currMessage =
          graph.getValueByKey(messages[index])! as MessageEntity;
      final prevMessage =
          graph.getValueByKey(messages[index + 1])! as MessageEntity;

      showDate =
          !areSameDay(currMessage.message.sendAt, prevMessage.message.sendAt);
    }

    String messageKey = messages[index];
    String messageId = getMessageIdFromMessageKey(messageKey);
    return ArchiveItem(
      showDate: showDate,
      messageKey: messageKey,
      onSelect: () {
        onSelect(messageId);
      },
      isSelected: () {
        return isSelected(messageId);
      },
      canShowMoreOptions: canDisplayMoreOptions,
      deleteMessage: (bool everyone) {
        deleteMessage(messageId, everyone);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) return;

        if (messagesSelected.isNotEmpty) {
          messagesSelected.clear();
          setState(() {});
          return;
        }

        if (focusNode.hasFocus) {
          FocusScope.of(context).unfocus();
          return;
        }

        context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: currTheme.surfaceContainer,
          title: InkWell(
            onTap: () {
              context.pushNamed(
                RouterConstants.messageArchiveProfile,
                pathParameters: {
                  "username": widget.username,
                },
              );
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(
                text: widget.username,
              )).then((value) {});
            },
            child: Row(
              spacing: Constants.gap,
              children: [
                UserWidget.avtar(
                  userKey: generateUserNodeKey(widget.username),
                ),
                UserWidget.info(
                  userKey: generateUserNodeKey(widget.username),
                ),
              ],
            ),
          ),
          actions: [
            if (messagesSelected.isNotEmpty)
              IconButton(
                onPressed: deleteSelected,
                color: currTheme.error,
                icon: Icon(Icons.delete_forever),
              ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: BlocBuilder<RealTimeBloc, RealTimeState>(
                buildWhen: (previousState, state) {
                  return (state is RealTimeNewMessageState &&
                          state.archiveUser == widget.username) ||
                      (state is RealTimeDeleteMessageState &&
                          state.archiveUser == widget.username);
                },
                builder: (context, state) {
                  final UserGraph graph = UserGraph();
                  String archiveKey = generateArchiveKey(widget.username);
                  String inboxKey = generateInboxItemKey(widget.username);

                  if (!graph.containsKey(archiveKey)) {
                    // check inbox if elements are present and show them before fetching archive messaging
                    return SizedBox.shrink();
                  }

                  final archive =
                      graph.getValueByKey(archiveKey)! as ArchiveEntity;
                  final messages = archive.currentSessionMessages
                      .toList(
                        growable: false,
                      )
                      .reversed
                      .toList(
                        growable: false,
                      );
                  return ListView.separated(
                    reverse: true,
                    itemCount: messages.length,
                    cacheExtent: height * 2,
                    padding: EdgeInsets.symmetric(
                      vertical: Constants.padding * 2,
                    ),
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: Constants.gap * 0.5,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return buildItem(context, index, messages.toList());
                    },
                  );
                },
              ),
            ),
            MessageInput(
              archiveUser: widget.username,
              focusNode: focusNode,
            ),
          ],
        ),
      ),
    );
  }
}
