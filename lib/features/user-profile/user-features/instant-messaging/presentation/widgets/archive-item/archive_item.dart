import 'dart:async';
import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/debounce/debounce.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/instant-messaging/message_preview.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/message-forward/message_forward.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/message-body-type/message_body_type.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/bloc/instant_messaging_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/provider/archive_message_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/discussions/discussion_preview_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/polls/poll_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_preview_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

part "archive_discussion.dart";
part "archive_external_resource.dart";
part "archive_poll.dart";
part "archive_post.dart";
part "archive_text.dart";
part "archive_user_profile.dart";

class ArchiveItem extends StatefulWidget {
  ArchiveItem({
    super.key,
    required this.messageKey,
    this.showDate = false,
  }) : messageId = getMessageIdFromMessageKey(messageKey);

  final String messageKey;
  final bool showDate;
  final String messageId;

  @override
  State<ArchiveItem> createState() => _ArchiveItemState();
}

class _ArchiveItemState extends State<ArchiveItem>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> animation;

  bool highlight = false;
  final highlightDebounce = Debounce(
    const Duration(
      milliseconds: 1500,
    ),
  );

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 100,
      ),
    );

    animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.375, 0.0),
    ).animate(
      CurvedAnimation(curve: Curves.decelerate, parent: controller),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void showMoreOptions(BuildContext context, bool self) {
    final width = MediaQuery.sizeOf(context).width;
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height / 2;

    final archiveMessageProvider = context.read<ArchiveMessageProvider>();
    bool deleting = false;
    final imBloc = context.read<InstantMessagingBloc>();

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final client = context.read<WebsocketClientProvider>().client;

    final UserGraph graph = UserGraph();
    MessageEntity messageEntity =
        graph.getValueByKey(widget.messageKey)! as MessageEntity;
    final message = messageEntity.message;

    void deleteMessage() {
      if (deleting) return;
      deleting = true;

      DeleteMessage deleteMessage = DeleteMessage(
        from: username,
        to: archiveMessageProvider.archiveUser,
        id: [widget.messageId],
      );

      // this is handled in message archive page
      context
          .read<InstantMessagingBloc>()
          .add(InstantMessagingDeleteMessageEvent(
            message: deleteMessage,
            client: client,
          ));
    }

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(
            bottom: Constants.padding,
          ),
          constraints: BoxConstraints(
            maxHeight: height,
          ),
          width: width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Constants.gap * 0.5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constants.padding,
                  ),
                  child: Heading.left(
                    "Message options...",
                    size: Constants.fontSize * 1.25,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Constants.gap * 0.5,
                  children: [
                    InkWell(
                      onTap: () {
                        archiveMessageProvider.selectMessage(widget.messageId);
                        context.pop();
                      },
                      child: _ArchiveItemOptions(
                        icon: Icons.check,
                        label: "Select",
                        color: currTheme.secondary,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        archiveMessageProvider.addReply(widget.messageId);
                        context.pop();
                      },
                      child: _ArchiveItemOptions(
                        icon: Icons.reply,
                        label: "Reply",
                        color: currTheme.secondary,
                      ),
                    ),
                    if (self && message.subject == MessageSubject.text)
                      InkWell(
                        onTap: () {
                          context.pop();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ChangeNotifierProvider.value(
                                value: archiveMessageProvider,
                                child: BlocProvider.value(
                                  value: imBloc,
                                  child: _EditMessage(
                                    messageId: widget.messageId,
                                    body: message.body,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: _ArchiveItemOptions(
                          icon: Icons.edit,
                          label: "Edit message",
                          color: currTheme.secondary,
                        ),
                      ),
                    if (message.subject == MessageSubject.text)
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                            text: message.body,
                          ));
                          context.pop();
                        },
                        child: _ArchiveItemOptions(
                          icon: Icons.copy,
                          label: "Copy message",
                          color: currTheme.secondary,
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        MessageForward.forward(
                          context: context,
                          messagesToForward: [message],
                        );
                      },
                      child: _ArchiveItemOptions(
                        icon: Icons.forward_to_inbox,
                        label: "Forward",
                        color: currTheme.secondary,
                      ),
                    ),
                    if (self)
                      InkWell(
                        onTap: () {
                          deleteMessage();
                          context.pop();
                        },
                        child: _ArchiveItemOptions(
                          icon: Icons.delete_forever,
                          label: "Delete message",
                          color: currTheme.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getMessageItem(MessageSubject subject, bool self) {
    final archiveProvider = context.read<ArchiveMessageProvider>();

    TextStyle metaDataStyle = TextStyle(
      fontSize: Constants.smallFontSize,
      fontWeight: FontWeight.bold,
      color: self
          ? archiveProvider.selfTextColor.withValues(
              alpha: 0.5,
            )
          : archiveProvider.textColor.withValues(
              alpha: 0.5,
            ),
    );

    Color bubbleColor = self
        ? archiveProvider.selfBackgroundColor
        : archiveProvider.backgroundColor;
    Color textColor =
        self ? archiveProvider.selfTextColor : archiveProvider.textColor;

    Widget body;
    switch (subject) {
      case MessageSubject.text:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
        );
      case MessageSubject.mediaBucketResource:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
        );
      case MessageSubject.mediaExternal:
        body = _ArchiveExternalResource(
          messageKey: widget.messageKey,
          metaDataStyle: metaDataStyle,
        );
      case MessageSubject.userLocation:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
        );
      case MessageSubject.dokiUser:
        body = _ArchiveUserProfile(
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
        );
      case MessageSubject.dokiPost:
        body = _ArchivePost(
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
          bubbleColor: bubbleColor,
          textColor: textColor,
        );
      case MessageSubject.dokiPage:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
        );
      case MessageSubject.dokiDiscussion:
        body = _ArchiveDiscussion(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
        );
      case MessageSubject.dokiPolls:
        body = _ArchivePoll(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: widget.messageKey,
        );
    }

    return body;
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final UserGraph graph = UserGraph();
    MessageEntity messageEntity =
        graph.getValueByKey(widget.messageKey)! as MessageEntity;
    final message = messageEntity.message;
    bool self = message.from == username;

    final alignment = self ? Alignment.topRight : Alignment.topLeft;
    final archiveProvider = context.read<ArchiveMessageProvider>();

    return _AddDayToast(
      date: message.sendAt,
      showDate: widget.showDate,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 10) {
            controller.forward().whenComplete(() {
              archiveProvider.addReply(widget.messageId);
              HapticFeedback.vibrate();
              controller.reverse().whenComplete(() {});
            });
          }
        },
        child: SlideTransition(
          key: ValueKey("${message.id}-archive-item-widget"),
          position: animation,
          child: BlocListener<UserActionBloc, UserActionState>(
            listenWhen: (previousState, state) {
              return state is UserActionNodeHighlightState &&
                  state.nodeId == message.id;
            },
            listener: (context, state) {
              if (!highlight) {
                setState(() {
                  highlight = true;
                });
              }
              highlightDebounce(() {
                if (highlight) {
                  setState(() {
                    highlight = false;
                  });
                }
              });
            },
            child: Builder(
              builder: (context) {
                final _ = context.watch<ArchiveMessageProvider>();

                return Container(
                  width: double.infinity,
                  color: highlight
                      ? currTheme.primaryContainer.withValues(
                          alpha: 0.75,
                        )
                      : archiveProvider.isSelected(widget.messageId)
                          ? currTheme.secondaryContainer
                          : Colors.transparent,
                  child: InkWell(
                    onLongPress: archiveProvider.canShowMoreOptions()
                        ? () => showMoreOptions(context, self)
                        : null,
                    onTap: archiveProvider.canShowMoreOptions()
                        ? null
                        : () => archiveProvider.selectMessage(widget.messageId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.padding,
                        vertical: Constants.padding * 0.5,
                      ),
                      child: FractionallySizedBox(
                        alignment: alignment,
                        widthFactor: 0.8,
                        child: Align(
                          alignment: alignment,
                          child: Column(
                            crossAxisAlignment: self
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              // show message reply
                              if (message.replyOn != null &&
                                  message.replyOn!.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    String messageKey =
                                        generateMessageKey(message.replyOn!);
                                    final messageEntity =
                                        graph.getValueByKey(messageKey);
                                    String displayMessageReply = "";
                                    bool notLoaded = false;

                                    if (messageEntity is MessageEntity) {
                                      displayMessageReply = messageReplyPreview(
                                          messageEntity.message.subject,
                                          messageEntity.message.body);
                                    } else {
                                      displayMessageReply =
                                          "Message could not be loaded.";
                                      notLoaded = true;
                                    }

                                    return Material(
                                      color: currTheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(
                                          Constants.radius * 0.5),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () {
                                          if (notLoaded) {
                                            showInfo(displayMessageReply);

                                            /// todo can get messages from this to present
                                            return;
                                          }

                                          final userActionBloc =
                                              context.read<UserActionBloc>();

                                          if (messageEntity is MessageEntity &&
                                              messageEntity.listIndex != null) {
                                            int messageIndex =
                                                messageEntity.listIndex!;
                                            final observerController = context
                                                .read<ArchiveMessageProvider>()
                                                .controller;

                                            if (observerController != null) {
                                              // immediately send the event in case widget is already in view
                                              userActionBloc.add(
                                                  UserActionNodeHighlightEvent(
                                                nodeId:
                                                    messageEntity.message.id,
                                              ));
                                              Timer(
                                                  const Duration(
                                                    milliseconds: Constants
                                                        .maxScrollDuration,
                                                  ), () {
                                                // fire highlight event
                                                userActionBloc.add(
                                                    UserActionNodeHighlightEvent(
                                                  nodeId:
                                                      messageEntity.message.id,
                                                ));
                                              });

                                              observerController.animateTo(
                                                index: messageIndex,
                                                duration: const Duration(
                                                  milliseconds: Constants
                                                      .maxScrollDuration,
                                                ),
                                                curve: Curves.fastOutSlowIn,
                                              );
                                            }
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              Constants.padding * 0.375),
                                          child: Column(
                                            children: [
                                              IntrinsicHeight(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  spacing:
                                                      Constants.gap * 0.625,
                                                  children: [
                                                    VerticalDivider(
                                                      thickness:
                                                          Constants.width *
                                                              0.375,
                                                      width: Constants.width *
                                                          0.375,
                                                      color: currTheme
                                                          .inversePrimary,
                                                    ),
                                                    Text(
                                                      displayMessageReply,
                                                      style: TextStyle(
                                                        fontSize: Constants
                                                            .smallFontSize,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: currTheme
                                                            .onSurface
                                                            .withValues(
                                                          alpha: 0.75,
                                                        ),
                                                      ),
                                                      softWrap: true,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              if (messageEntity.message.forwarded)
                                const Text("Forwarded",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: Constants.smallFontSize * 0.875,
                                    )),
                              getMessageItem(message.subject, self),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AddDayToast extends StatelessWidget {
  const _AddDayToast({
    required this.child,
    required this.date,
    required this.showDate,
  });

  final Widget child;
  final DateTime date;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    if (!showDate) return child;

    final currTheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: Constants.gap * 0.5,
              horizontal: Constants.gap * 0.75,
            ),
            decoration: BoxDecoration(
              color: currTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Constants.radius),
            ),
            child: Text(formatDateToWeekDays(date)),
          ),
        ),
        const SizedBox(
          height: Constants.gap * 1.25,
        ),
        child,
      ],
    );
  }
}

class _ArchiveItemOptions extends StatelessWidget {
  const _ArchiveItemOptions({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.padding),
      child: Row(
        spacing: Constants.gap * 1,
        children: [
          Icon(
            icon,
            color: color,
            size: Constants.iconButtonSize * 0.5,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: Constants.fontSize * 0.875,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditMessage extends StatefulWidget {
  const _EditMessage({
    required this.messageId,
    required this.body,
  });

  final String messageId;
  final String body;

  @override
  State<_EditMessage> createState() => _EditMessageState();
}

class _EditMessageState extends State<_EditMessage> {
  late final TextEditingController controller =
      TextEditingController(text: widget.body);

  /// handle duplicates during reconnect attempt
  bool updating = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final client = context.read<WebsocketClientProvider>().client;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return BlocListener<InstantMessagingBloc, InstantMessagingState>(
      listenWhen: (previousState, state) {
        return state is InstantMessagingEditMessageSuccessState ||
            state is InstantMessagingEditMessageSuccessState;
      },
      listener: (context, state) {
        updating = false;
        if (state is InstantMessagingEditMessageErrorState) {
          showError(state.message);
          return;
        }

        if (state is! InstantMessagingEditMessageSuccessState) return;

        context.read<RealTimeBloc>().add(RealTimeEditMessageEvent(
              message: state.message,
              username: username,
            ));

        showSuccess("Message edited.");
        if (mounted) context.pop();
      },
      child: AlertDialog(
        title: const Text("Edit message"),
        content: SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 6,
            autofocus: true,
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                Constants.messageLimit,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
            ],
            decoration: const InputDecoration(
              hintText: "Edit your message here...",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String newBody = controller.text.trim();

              if (newBody.isEmpty) {
                showError("Message can't be empty.");
                return;
              }
              if (updating) return;
              updating = true;

              final archiveMessageProvider =
                  context.read<ArchiveMessageProvider>();

              EditMessage editedMessage = EditMessage(
                from: username,
                to: archiveMessageProvider.archiveUser,
                id: widget.messageId,
                body: newBody,
                editedOn: DateTime.now(),
              );

              context
                  .read<InstantMessagingBloc>()
                  .add(InstantMessagingEditMessageEvent(
                    message: editedMessage,
                    client: client,
                  ));
            },
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }
}
