import 'dart:collection';

import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/instant-messaging/message_preview.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/typing-status/typing_status_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MessageInboxPage extends StatelessWidget {
  const MessageInboxPage({super.key});

  MessageEntity? findFirstValidMessage(Queue<String> message) {
    UserGraph graph = UserGraph();
    for (String messageKey in message) {
      if (!graph.containsKey(messageKey)) continue;

      final item = graph.getValueByKey(messageKey)! as MessageEntity;
      if (item.deleted) continue;
      return item;
    }

    return null;
  }

  Widget buildItems(BuildContext context, int index, List<String> items) {
    UserGraph graph = UserGraph();
    final currentUser =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final inboxItemKey = items[index];
    final username = getUsernameFromInboxItemKey(inboxItemKey);
    final userKey = generateUserNodeKey(username);

    final inboxItemEntity =
        graph.getValueByKey(inboxItemKey)! as InboxItemEntity;

    final latestMessage = findFirstValidMessage(inboxItemEntity.messages);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool shrink = constraints.maxWidth < 320;
        final currTheme = Theme.of(context).colorScheme;
        // bool superShrink = constraints.maxWidth < 290;

        // double shrinkFactor = shrink ? 0.75 : 1;
        bool selected = false;

        return ListTile(
          isThreeLine: true,
          onTap: () {
            context.pushNamed(
              RouterConstants.messageArchive,
              pathParameters: {
                "username": username,
              },
            );
          },
          selectedTileColor: currTheme.primaryContainer,
          selectedColor: currTheme.onPrimaryContainer,
          selected: selected,
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          leading: selected
              ? CircleAvatar(
                  backgroundColor: currTheme.onPrimaryContainer,
                  child: Icon(
                    Icons.check,
                    color: currTheme.primaryContainer,
                  ),
                )
              : shrink
                  ? UserWidget.avtarSmall(
                      key: ValueKey("$userKey-small-avtar"),
                      userKey: userKey,
                    )
                  : UserWidget.avtar(
                      userKey: userKey,
                    ),
          title: UserWidget.info(
            userKey: userKey,
          ),
          subtitle: Builder(builder: (context) {
            if (true) {
              return TypingStatusWidget.canHide(
                username: getUsernameFromUserKey(userKey),
              );
            }

            return latestMessage == null
                ? Text("Start the conversation.")
                : Text(messagePreview(latestMessage.message, currentUser));
          }),
          trailing: latestMessage == null
              ? null
              : Text(formatDateTimeToTimeString(latestMessage.message.sendAt)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message Inbox"),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(RouterConstants.messageInboxSearch);
            },
            icon: Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: BlocBuilder<RealTimeBloc, RealTimeState>(
        buildWhen: (previousState, state) {
          return state is RealTimeNewMessageState;
        },
        builder: (context, state) {
          final UserGraph graph = UserGraph();
          final inboxKey = generateInboxKey();

          if (!graph.containsKey(inboxKey)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "No inbox items right now.",
                    style: TextStyle(
                      fontSize: Constants.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }

          final inbox = graph.getValueByKey(inboxKey)! as InboxEntity;
          final items = inbox.items
              .toList(
                growable: false,
              )
              .reversed
              .toList(
                growable: false,
              );

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              vertical: Constants.padding,
            ),
            itemBuilder: (BuildContext context, int index) {
              return buildItems(context, index, items);
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: Constants.gap,
              );
            },
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
