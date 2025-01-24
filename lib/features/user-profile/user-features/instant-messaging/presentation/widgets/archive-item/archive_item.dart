import 'dart:async';
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/message-body-type/message_body_type.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

part "archive_text.dart";

class ArchiveItem extends StatelessWidget {
  const ArchiveItem({
    super.key,
    required this.messageKey,
    this.showDate = false,
  });

  final String messageKey;
  final bool showDate;

  Widget messageContainer(
      Widget child, BuildContext context, bool self, DateTime sendAt) {
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
              color: currTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(displayDateDifference(sendAt)),
          ),
        ),
        const SizedBox(
          height: Constants.gap * 1.25,
        ),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final UserGraph graph = UserGraph();
    if (!graph.containsKey(messageKey)) {
      return SizedBox.shrink();
    }

    MessageEntity messageEntity =
        graph.getValueByKey(messageKey)! as MessageEntity;
    final message = messageEntity.message;
    bool self = message.from == username;

    final alignment = self ? Alignment.topRight : Alignment.topLeft;

    Widget body;
    switch (message.subject) {
      case MessageSubject.text:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.mediaBucketResource:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.mediaExternal:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.userLocation:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.dokiUser:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.dokiPost:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.dokiPage:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.dokiDiscussion:
        body = _ArchiveText(
          messageKey: messageKey,
        );
      case MessageSubject.dokiPolls:
        body = _ArchiveText(
          messageKey: messageKey,
        );
    }

    Widget child = FractionallySizedBox(
      alignment: alignment,
      widthFactor: 0.8,
      child: Align(
        alignment: alignment,
        child: body,
      ),
    );

    return messageContainer(child, context, self, message.sendAt);
  }
}
