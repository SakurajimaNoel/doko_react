import 'dart:math';

import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/constrained-box/expanded_box.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/bloc/instant_messaging_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/archive-item-options/archive_item_options.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/typing-status/typing_status_widget_wrapper.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MessageInboxPage extends StatefulWidget {
  const MessageInboxPage({super.key});

  @override
  State<MessageInboxPage> createState() => _MessageInboxPageState();
}

class _MessageInboxPageState extends State<MessageInboxPage> {
  bool loading = false;

  void showInboxItemOptions(
      BuildContext context, String user, String inboxUser) {
    final width = min(MediaQuery.sizeOf(context).width, Constants.compact);
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height / 2;

    final instantMessagingBloc = context.read<InstantMessagingBloc>();

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
            physics: const AlwaysScrollableScrollPhysics(),
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
                    "Inbox options...",
                    size: Constants.fontSize * 1.25,
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.pop();
                    context.pushNamed(RouterConstants.userProfile,
                        pathParameters: {
                          "username": inboxUser,
                        });
                  },
                  child: ArchiveItemOptions(
                    avtar: UserWidget.avtarSmall(
                      userKey: generateUserNodeKey(inboxUser),
                    ),
                    label: "Profile",
                    color: currTheme.secondary,
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.pop();
                    instantMessagingBloc.add(InstantMessagingDeleteInboxEntry(
                      user: user,
                      inboxUser: inboxUser,
                    ));
                  },
                  child: ArchiveItemOptions(
                    icon: Icons.delete,
                    label: "Remove",
                    color: currTheme.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildItems(BuildContext context, int index) {
    final currTheme = Theme.of(context).colorScheme;
    UserGraph graph = UserGraph();

    String key = generateInboxKey();
    InboxEntity inbox = graph.getValueByKey(key)! as InboxEntity;
    List<String> items = inbox.items;

    if (index >= items.length) {
      if (!inbox.pageInfo.hasNextPage) {
        return const SizedBox.shrink();
      }

      if (!loading) {
        loading = true;
        context.read<RealTimeBloc>().add(RealTimeInboxGetEvent(
                details: InboxQueryInput(
              cursor: inbox.pageInfo.endCursor ?? "",
              username: (context.read<UserBloc>().state as UserCompleteState)
                  .username,
            )));
      }

      return const Center(
        child: LoadingWidget.small(),
      );
    }

    final inboxItemKey = items[index];
    final username = getUsernameFromInboxItemKey(inboxItemKey);
    final userKey = generateUserNodeKey(username);

    final inboxItemEntity =
        graph.getValueByKey(inboxItemKey)! as InboxItemEntity;

    String? inboxText =
        inboxItemEntity.displayText ?? "Start the conversation.";
    String? inboxActivityTime;
    if (inboxItemEntity.lastActivityTime != null) {
      inboxActivityTime = formatDateForInbox(inboxItemEntity.lastActivityTime!);
    }

    return ListTile(
      onTap: () {
        context.pushNamed(
          RouterConstants.messageArchive,
          pathParameters: {
            "username": username,
          },
        );
      },
      onLongPress: () {
        showInboxItemOptions(
          context,
          (context.read<UserBloc>().state as UserCompleteState).username,
          username,
        );
      },
      selectedTileColor: currTheme.primaryContainer,
      selectedColor: currTheme.onPrimaryContainer,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      minVerticalPadding: Constants.padding * 0.5,
      leading: UserWidget.avtar(
        userKey: userKey,
      ),
      title: UserWidget.name(
        userKey: userKey,
        bold: true,
      ),
      subtitle: TypingStatusWidgetWrapper.text(
        username: username,
        child: Text(
          inboxText,
          style: TextStyle(
            fontSize: inboxItemEntity.unread
                ? Constants.fontSize * 0.875
                : Constants.smallFontSize,
            fontWeight:
                inboxItemEntity.unread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Constants.gap * 0.25,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (inboxActivityTime != null) Text(inboxActivityTime),
          if (inboxItemEntity.unread)
            DecoratedBox(
              decoration: BoxDecoration(
                color: currTheme.primaryContainer,
                borderRadius: BorderRadius.circular(Constants.radius * 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Constants.padding * 0.125,
                  horizontal: Constants.padding * 0.25,
                ),
                child: Text(
                  "New",
                  style: TextStyle(
                    fontSize: Constants.smallFontSize,
                    fontWeight: FontWeight.w600,
                    color: currTheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
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
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<RealTimeBloc>()
              ..add(RealTimeInboxGetEvent(
                  details: InboxQueryInput(
                cursor: "",
                username: (context.read<UserBloc>().state as UserCompleteState)
                    .username,
              ))),
          ),
          BlocProvider(
            create: (context) => serviceLocator<InstantMessagingBloc>(),
          ),
        ],
        child: BlocConsumer<RealTimeBloc, RealTimeState>(
          listenWhen: (prevState, state) {
            return state is RealTimeUserInboxUpdateState;
          },
          listener: (context, state) {
            loading = false;
          },
          buildWhen: (previousState, state) {
            return state is RealTimeUserInboxUpdateState;
          },
          builder: (context, _) {
            final UserGraph graph = UserGraph();
            final inboxKey = generateInboxKey();

            bool loading = !graph.containsKey(inboxKey);

            if (loading) {
              return const Center(
                child: LoadingWidget(),
              );
            }

            final inbox = graph.getValueByKey(inboxKey)! as InboxEntity;
            final items = inbox.items;

            if (items.isEmpty) {
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

            return ListView.separated(
              padding: const EdgeInsets.only(
                bottom: Constants.padding,
                top: Constants.padding * 0.5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return ExpandedBox(
                  child: buildItems(context, index),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: Constants.gap,
                );
              },
              itemCount: items.length + 1,
            );
          },
        ),
      ),
    );
  }
}
