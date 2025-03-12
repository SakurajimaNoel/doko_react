import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/content-meta-data-widget/users_tagged_profile_avtar_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentMetaDataPreviewWidget extends StatelessWidget {
  const ContentMetaDataPreviewWidget({
    super.key,
    required this.nodeType,
    required this.nodeId,
  });

  final DokiNodeType nodeType;
  final String nodeId;

  @override
  Widget build(BuildContext context) {
    final nodeKey = nodeType.keyGenerator(nodeId);

    final UserGraph graph = UserGraph();
    final node = graph.getValueByKey(nodeKey)! as GraphEntityWithUserAction;
    final usersTagged = node.usersTagged;

    return Row(
      spacing: Constants.gap * 0.75,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        usersTagged.isNotEmpty
            ? UsersTaggedAvtarWidget(
                usersTagged: usersTagged,
                nodeCreatedBy: node.createdBy,
              )
            : UserWidget.avtarSmall(
                userKey: node.createdBy,
              ),
        Expanded(
          child: UserWidget.info(
            userKey: node.createdBy,
          ),
        ),
        BlocBuilder<UserActionBloc, UserActionState>(
          buildWhen: (previousState, state) {
            return (state is UserActionNodeActionState &&
                    state.nodeId == node.id) ||
                (state is UserActionPrimaryNodeRefreshState &&
                    state.nodeId == node.id);
          },
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: Constants.gap * 0.125,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ContentStats(
                  count: node.likesCount,
                  icon: Icons.thumb_up,
                ),
                _ContentStats(
                  count: node.commentsCount,
                  icon: Icons.comment_rounded,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ContentStats extends StatelessWidget {
  const _ContentStats({
    required this.count,
    required this.icon,
  });

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Constants.gap * 0.25,
      children: [
        Text(
          displayNumberFormat(count),
          style: const TextStyle(
            fontSize: Constants.smallFontSize,
          ),
        ),
        Icon(
          icon,
          size: Constants.iconButtonSize * 0.275,
        )
      ],
    );
  }
}
