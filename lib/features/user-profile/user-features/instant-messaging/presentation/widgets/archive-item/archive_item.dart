import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart'
    hide ValueGetter, ValueSetter;
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/message-body-type/message_body_type.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/provider/archive_message_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_preview_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

part "archive_external_resource.dart";
part "archive_post.dart";
part "archive_text.dart";
part "archive_user_profile.dart";

class ArchiveItem extends StatelessWidget {
  ArchiveItem({
    super.key,
    required this.messageKey,
    this.showDate = false,
  }) : messageId = getMessageIdFromMessageKey(messageKey);

  final String messageKey;
  final bool showDate;
  final String messageId;

  void showMoreOptions(
      BuildContext context, bool self, MessageSubject subject, String body) {
    final width = MediaQuery.sizeOf(context).width;
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height / 2;
    final archiveMessageProvider = context.read<ArchiveMessageProvider>();

    void deleteMessage({
      required bool everyone,
    }) {
      final client = context.read<WebsocketClientProvider>().client;
      if (client == null || !client.isActive) {
        showError(context, "You are not connected.");
      }

      final username =
          (context.read<UserBloc>().state as UserCompleteState).username;
      final archiveMessageProvider = context.read<ArchiveMessageProvider>();

      DeleteMessage deleteMessage = DeleteMessage(
        from: username,
        to: archiveMessageProvider.archiveUser,
        id: [messageId],
        everyone: everyone,
      );

      bool result = client!.deleteMessage(deleteMessage);
      if (result) {
        context.read<RealTimeBloc>().add(RealTimeDeleteMessageEvent(
              message: deleteMessage,
              username: username,
            ));
        archiveMessageProvider.clearSelect();
      } else {
        showError(context, "Failed to delete message.");
      }
    }

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.padding,
                  ),
                  child: Heading.left(
                    "Message options...",
                    size: Constants.heading4,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Constants.gap * 0.5,
                  children: [
                    InkWell(
                      onTap: () {
                        archiveMessageProvider.selectMessage(messageId);
                        context.pop();
                      },
                      child: _ArchiveItemOptions(
                        icon: Icons.check,
                        label: "Select",
                        color: currTheme.secondary,
                      ),
                    ),
                    if (self && subject == MessageSubject.text)
                      InkWell(
                        onTap: () {
                          context.pop();
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ChangeNotifierProvider.value(
                                value: archiveMessageProvider,
                                child: _EditMessage(
                                  messageId: messageId,
                                  body: body,
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
                    if (subject == MessageSubject.text)
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                            text: body,
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
                        deleteMessage(
                          everyone: false,
                        );
                        context.pop();
                      },
                      child: _ArchiveItemOptions(
                        icon: Icons.delete,
                        label: "Delete",
                        color: currTheme.error,
                      ),
                    ),
                    if (self)
                      InkWell(
                        onTap: () {
                          deleteMessage(
                            everyone: true,
                          );
                          context.pop();
                        },
                        child: _ArchiveItemOptions(
                          icon: Icons.delete_forever,
                          label: "Delete for everyone",
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

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final UserGraph graph = UserGraph();
    MessageEntity messageEntity =
        graph.getValueByKey(messageKey)! as MessageEntity;
    final message = messageEntity.message;
    bool self = message.from == username;

    final alignment = self ? Alignment.topRight : Alignment.topLeft;
    final archiveProvider = context.read<ArchiveMessageProvider>();

    TextStyle metaDataStyle = TextStyle(
      fontSize: Constants.smallFontSize,
      fontWeight: FontWeight.w600,
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
    switch (message.subject) {
      case MessageSubject.text:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.mediaBucketResource:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.mediaExternal:
        body = _ArchiveExternalResource(
          messageKey: messageKey,
          metaDataStyle: metaDataStyle,
        );
      case MessageSubject.userLocation:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.dokiUser:
        body = _ArchiveUserProfile(
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.dokiPost:
        body = _ArchivePost(
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
          bubbleColor: bubbleColor,
          textColor: textColor,
        );
      case MessageSubject.dokiPage:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.dokiDiscussion:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.dokiPolls:
        body = _ArchiveText(
          bubbleColor: bubbleColor,
          textColor: textColor,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
    }

    return _AddDayToast(
      date: message.sendAt,
      showDate: showDate,
      child: Builder(builder: (context) {
        final _ = context.watch<ArchiveMessageProvider>();

        return Container(
          width: double.infinity,
          color: archiveProvider.isSelected(messageId)
              ? currTheme.secondaryContainer
              : Colors.transparent,
          child: InkWell(
            onLongPress: archiveProvider.canShowMoreOptions()
                ? () => showMoreOptions(
                    context, self, message.subject, message.body)
                : null,
            onTap: archiveProvider.canShowMoreOptions()
                ? null
                : () => archiveProvider.selectMessage(messageId),
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
                  child: body,
                ),
              ),
            ),
          ),
        );
      }),
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
            padding: EdgeInsets.symmetric(
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
        spacing: Constants.gap * 1.5,
        children: [
          Icon(
            icon,
            color: color,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: Constants.fontSize,
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AlertDialog(
      title: Text("Edit message"),
      content: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              minLines: 4,
              maxLines: 8,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            String newBody = controller.text.trim();

            if (newBody.isEmpty) {
              showError(context, "Message can't be empty.");
              return;
            }

            final client = context.read<WebsocketClientProvider>().client;
            if (client == null || !client.isActive) {
              showError(context, "You are not connected.");
            }

            final archiveMessageProvider =
                context.read<ArchiveMessageProvider>();
            final username =
                (context.read<UserBloc>().state as UserCompleteState).username;
            EditMessage editedMessage = EditMessage(
              from: username,
              to: archiveMessageProvider.archiveUser,
              id: widget.messageId,
              body: newBody,
            );

            if (client!.editMessage(editedMessage)) {
              // success
              showSuccess(context, "Message edited.");
              context.read<RealTimeBloc>().add(RealTimeEditMessageEvent(
                    message: editedMessage,
                    username: username,
                  ));
            } else {
              showError(context, "Failed to edit message.");
              return;
            }

            context.pop();
          },
          child: Text("Edit"),
        ),
      ],
    );
  }
}
