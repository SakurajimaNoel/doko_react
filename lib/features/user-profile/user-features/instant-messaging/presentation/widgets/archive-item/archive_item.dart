import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart'
    hide ValueGetter, ValueSetter;
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/message-body-type/message_body_type.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/post_preview_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

part "archive_external_resource.dart";
part "archive_post.dart";
part "archive_text.dart";
part "archive_user_profile.dart";

class ArchiveItem extends StatelessWidget {
  const ArchiveItem({
    super.key,
    required this.messageKey,
    this.showDate = false,
    required this.onSelect,
    required this.isSelected,
    required this.canShowMoreOptions,
    required this.deleteMessage,
  });

  final String messageKey;
  final bool showDate;
  final VoidCallback onSelect;
  final ValueGetter<bool> isSelected;
  final ValueGetter<bool> canShowMoreOptions;
  final ValueSetter<bool> deleteMessage;

  void showMoreOptions(
      BuildContext context, bool self, MessageSubject subject, String body) {
    final width = MediaQuery.sizeOf(context).width;
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height / 2;

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
                        onSelect();
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
                          showInfo(context, "Coming soon");
                          // context.pop();
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
                        deleteMessage(false);
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
                          deleteMessage(true);
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
    ).whenComplete(() {
      FocusManager.instance.primaryFocus?.unfocus();
    });
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

    TextStyle metaDataStyle = TextStyle(
      fontSize: Constants.smallFontSize,
      fontWeight: FontWeight.w600,
      color: self
          ? currTheme.onPrimaryContainer.withValues(
              alpha: 0.5,
            )
          : currTheme.onSurface.withValues(
              alpha: 0.5,
            ),
    );

    List<Color> colors = self
        ? [
            currTheme.secondaryContainer,
            currTheme.primaryContainer,
          ]
        : [
            currTheme.surfaceContainerLowest,
            currTheme.surfaceContainerHighest,
          ];

    Widget body;
    switch (message.subject) {
      case MessageSubject.text:
        body = _ArchiveText(
          colors: colors,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.mediaBucketResource:
        body = _ArchiveText(
          colors: colors,
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
          colors: colors,
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
          colors: colors,
        );
      case MessageSubject.dokiPage:
        body = _ArchiveText(
          colors: colors,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.dokiDiscussion:
        body = _ArchiveText(
          colors: colors,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
      case MessageSubject.dokiPolls:
        body = _ArchiveText(
          colors: colors,
          metaDataStyle: metaDataStyle,
          messageKey: messageKey,
        );
    }

    return _AddDayToast(
      date: message.sendAt,
      showDate: showDate,
      child: Container(
        width: double.infinity,
        color: isSelected() ? currTheme.secondaryContainer : Colors.transparent,
        child: InkWell(
          onLongPress: canShowMoreOptions()
              ? () =>
                  showMoreOptions(context, self, message.subject, message.body)
              : null,
          onTap: canShowMoreOptions() ? null : onSelect,
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
            // size: Constants.iconButtonSize ,
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
