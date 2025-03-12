import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InboxWidget extends StatelessWidget {
  const InboxWidget({
    super.key,
    this.inNavRail = false,
  });

  final bool inNavRail;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.pushNamed(RouterConstants.messageInbox);
      },
      iconSize: inNavRail ? 24 : null,
      style: inNavRail
          ? IconButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.all(6),
            )
          : null,
      icon: BlocBuilder<RealTimeBloc, RealTimeState>(
        buildWhen: (previousState, state) {
          return state is RealTimeUserInboxUpdateState;
        },
        builder: (context, state) {
          final UserGraph graph = UserGraph();
          final inboxKey = generateInboxKey();

          int unreadCount = 0;
          if (graph.containsKey(inboxKey)) {
            final inbox = graph.getValueByKey(inboxKey)! as InboxEntity;
            for (String key in inbox.items) {
              final inboxItemEntity =
                  graph.getValueByKey(key)! as InboxItemEntity;

              if (inboxItemEntity.unread) {
                unreadCount++;
              }
            }
          }

          bool showLabel = unreadCount > 0;
          String labelText = unreadCount > 15 ? "15+" : unreadCount.toString();

          return Badge(
            label: Text(labelText),
            isLabelVisible: showLabel,
            child: const Icon(
              Icons.chat,
            ),
          );
        },
      ),
    );
  }
}
