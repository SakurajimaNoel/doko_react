import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/typing-status/typing_status_widget_wrapper.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MessageInboxPage extends StatelessWidget {
  const MessageInboxPage({super.key});

  Widget buildItems(BuildContext context, int index, List<String> items) {
    final currTheme = Theme.of(context).colorScheme;

    UserGraph graph = UserGraph();

    final inboxItemKey = items[index];
    final username = getUsernameFromInboxItemKey(inboxItemKey);
    final userKey = generateUserNodeKey(username);

    final inboxItemEntity =
        graph.getValueByKey(inboxItemKey)! as InboxItemEntity;

    String? inboxText = inboxItemEntity.displayText ?? "Start the conversation";
    String? inboxActivityTime;
    if (inboxItemEntity.lastActivityTime != null) {
      inboxActivityTime =
          formatDateTimeToTimeString(inboxItemEntity.lastActivityTime!);
    }

    bool selected = false;
    return ListTile(
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      minVerticalPadding: Constants.padding * 0.5,
      leading: selected
          ? CircleAvatar(
              backgroundColor: currTheme.onPrimaryContainer,
              child: Icon(
                Icons.check,
                color: currTheme.primaryContainer,
              ),
            )
          : UserWidget.avtar(
              userKey: userKey,
            ),
      title: UserWidget.name(
        userKey: userKey,
        bold: true,
        baseFontSize: Constants.smallFontSize * 1.125,
        trim: 20,
      ),
      subtitle: TypingStatusWidgetWrapper.text(
        username: username,
        child: Text(inboxText),
      ),
      trailing: inboxActivityTime == null ? null : Text(inboxActivityTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Inbox"),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: Constants.gap,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(RouterConstants.messageInboxSearch);
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: BlocBuilder<RealTimeBloc, RealTimeState>(
        buildWhen: (previousState, state) {
          return state is RealTimeNewMessageState ||
              state is RealTimeEditMessageState ||
              state is RealTimeDeleteMessageState;
        },
        builder: (context, state) {
          final UserGraph graph = UserGraph();
          final inboxKey = generateInboxKey();

          if (!graph.containsKey(inboxKey)) {
            return const Column(
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
            padding: const EdgeInsets.only(
              bottom: Constants.padding,
              top: Constants.padding * 0.5,
            ),
            itemBuilder: (BuildContext context, int index) {
              return buildItems(context, index, items);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
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
