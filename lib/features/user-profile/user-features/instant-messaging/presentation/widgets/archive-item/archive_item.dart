import 'dart:collection';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/message-body-type/message_body_type.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

part "archive_external_resource.dart";
part "archive_text.dart";
part "archive_user_profile.dart";

class ArchiveItem extends StatelessWidget {
  const ArchiveItem({
    super.key,
    required this.messageKey,
    this.showDate = false,
  });

  final String messageKey;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    String messageId = getMessageIdFromMessageKey(messageKey);
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return BlocBuilder<RealTimeBloc, RealTimeState>(
      buildWhen: (previousState, state) {
        return (state is RealTimeDeleteMessageState &&
            state.id.contains(messageId));
      },
      builder: (context, state) {
        final UserGraph graph = UserGraph();
        if (!graph.containsKey(messageKey)) {
          return SizedBox.shrink();
        }

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

        Widget body;
        switch (message.subject) {
          case MessageSubject.text:
            body = _ArchiveText(
              metaDataStyle: metaDataStyle,
              messageKey: messageKey,
            );
          case MessageSubject.mediaBucketResource:
            body = _ArchiveText(
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
              metaDataStyle: metaDataStyle,
              messageKey: messageKey,
            );
          case MessageSubject.dokiUser:
            body = _ArchiveUserProfile(
              metaDataStyle: metaDataStyle,
              messageKey: messageKey,
            );
          case MessageSubject.dokiPost:
            body = _ArchiveText(
              metaDataStyle: metaDataStyle,
              messageKey: messageKey,
            );
          case MessageSubject.dokiPage:
            body = _ArchiveText(
              metaDataStyle: metaDataStyle,
              messageKey: messageKey,
            );
          case MessageSubject.dokiDiscussion:
            body = _ArchiveText(
              metaDataStyle: metaDataStyle,
              messageKey: messageKey,
            );
          case MessageSubject.dokiPolls:
            body = _ArchiveText(
              metaDataStyle: metaDataStyle,
              messageKey: messageKey,
            );
        }

        return _AddDayToast(
          date: message.sendAt,
          showDate: showDate,
          self: self,
          child: FractionallySizedBox(
            alignment: alignment,
            widthFactor: 0.8,
            child: Align(
              alignment: alignment,
              child: messageEntity.deleted ? null : body,
            ),
          ),
        );
      },
    );
  }
}

class _AddDayToast extends StatelessWidget {
  const _AddDayToast({
    required this.child,
    required this.date,
    required this.showDate,
    required this.self,
  });

  final Widget child;
  final DateTime date;
  final bool showDate;
  final bool self;

  @override
  Widget build(BuildContext context) {
    if (!showDate) return child;

    final currTheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
          self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
            child: Text(displayDateDifference(date)),
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
