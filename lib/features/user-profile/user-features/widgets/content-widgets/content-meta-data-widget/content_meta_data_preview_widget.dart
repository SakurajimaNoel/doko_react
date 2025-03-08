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
    required this.width,
  });

  final DokiNodeType nodeType;
  final String nodeId;
  final double width;

  @override
  Widget build(BuildContext context) {
    final nodeKey = nodeType.keyGenerator(nodeId);

    final UserGraph graph = UserGraph();
    final node = graph.getValueByKey(nodeKey)! as GraphEntityWithUserAction;
    final usersTagged = node.usersTagged;

    bool shrink = width < 220;
    bool superShrink = width < 175;
    double shrinkFactor = shrink ? 0.75 : 1;

    return Row(
      spacing: Constants.gap * 0.75 * shrinkFactor,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        usersTagged.isNotEmpty
            ? UsersTaggedAvtarWidget(
                usersTagged: usersTagged,
                nodeCreatedBy: node.createdBy,
              )
            : UserWidget.avtarSmall(
                userKey: node.createdBy,
              ),
        SizedBox(
          child: UserWidget.infoSmall(
            userKey: node.createdBy,
            trim: superShrink ? 12 : 16,
            baseFontSize: Constants.smallFontSize,
          ),
        ),
        if (!shrink) ...[
          const Spacer(),
          BlocBuilder<UserActionBloc, UserActionState>(
            buildWhen: (previousState, state) {
              return (state is UserActionNodeActionState &&
                      state.nodeId == node.id) ||
                  (state is UserActionPrimaryNodeRefreshState &&
                      state.nodeId == node.id);
            },
            builder: (context, state) {
              if (shrink) return const SizedBox.shrink();

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: Constants.gap * 0.125,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    spacing: Constants.gap * 0.25,
                    children: [
                      Text(
                        displayNumberFormat(node.likesCount),
                        style: const TextStyle(
                          fontSize: Constants.smallFontSize * 0.875,
                        ),
                      ),
                      const Icon(
                        Icons.thumb_up,
                        size: Constants.iconButtonSize * 0.25,
                      )
                    ],
                  ),
                  Row(
                    spacing: Constants.gap * 0.25,
                    children: [
                      Text(
                        displayNumberFormat(node.commentsCount),
                        style: const TextStyle(
                          fontSize: Constants.smallFontSize * 0.875,
                        ),
                      ),
                      const Icon(
                        Icons.comment_rounded,
                        size: Constants.iconButtonSize * 0.25,
                      )
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
