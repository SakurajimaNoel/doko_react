import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/widgets/like-widget/like_widget.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentActionWidget extends StatelessWidget {
  const ContentActionWidget({
    super.key,
    required this.nodeId,
    required this.nodeType,
    required this.isNodePage,
    required this.redirectToNodePage,
  });

  final String nodeId;
  final DokiNodeType nodeType;
  final bool isNodePage;
  final VoidCallback redirectToNodePage;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final String username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    final nodeKey = nodeType.keyGenerator(nodeId);

    final graph = UserGraph();

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionNodeActionState && state.nodeId == nodeId) ||
            (state is UserActionPrimaryNodeRefreshState &&
                state.nodeId == nodeId);
      },
      builder: (context, state) {
        var node = graph.getValueByKey(nodeKey)! as GraphEntityWithUserAction;

        return LayoutBuilder(
          builder: (context, constraints) {
            bool shrink = constraints.maxWidth < 275;
            double shrinkFactor = shrink ? 0.475 : 1;
            double buttonShrinkFactor = shrink ? 0.5 : 1;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.padding,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: Constants.gap,
                    children: [
                      Text(
                        "${displayNumberFormat(node.likesCount)} Like${node.likesCount > 1 ? "s" : ""}",
                        style: TextStyle(
                          fontSize: shrink ? Constants.smallFontSize : null,
                        ),
                      ),
                      Text(
                        "${displayNumberFormat(node.commentsCount)} Comment${node.commentsCount > 1 ? "s" : ""}",
                        style: TextStyle(
                          fontSize: shrink ? Constants.smallFontSize : null,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    thickness: Constants.dividerThickness * 0.75,
                  ),
                  Row(
                    spacing: Constants.gap * shrinkFactor,
                    children: [
                      LikeWidget(
                        shrinkFactor: shrink ? 0.875 : 1,
                        onPress: () {
                          UserNodeLikeAction payload = UserNodeLikeAction(
                            from: username,
                            to: getUsernameFromUserKey(node.createdBy),
                            isLike: node.userLike,
                            likeCount: node.likesCount,
                            commentCount: node.commentsCount,
                            nodeId: node.id,
                            nodeType: nodeType.nodeType,
                            parents: [], // for root node no requirement to get parents
                          );
                          context
                              .read<UserActionBloc>()
                              .add(UserActionNodeLikeEvent(
                                nodeId: nodeId,
                                nodeType: nodeType,
                                userLike: !node.userLike,
                                username: username,
                                client: context
                                    .read<WebsocketClientProvider>()
                                    .client,
                                remotePayload: payload,
                              ));
                        },
                        userLike: node.userLike,
                      ),
                      TextButton(
                        onPressed: () {
                          if (isNodePage) {
                            context.read<NodeCommentProvider>()
                              ..focusNode.requestFocus()
                              ..resetCommentTarget();
                            return;
                          }

                          redirectToNodePage();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: currTheme.secondary,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.padding * buttonShrinkFactor,
                            vertical: Constants.padding * 0.425,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Comment",
                          style: TextStyle(
                            fontSize: shrink ? Constants.smallFontSize : null,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          if (isNodePage) {
                            // remove focus
                            FocusManager.instance.primaryFocus?.unfocus();
                          }

                          Share.share(
                            context: context,
                            subject: nodeType.messageSubject,
                            nodeIdentifier: node.id,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: currTheme.secondary,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.padding * buttonShrinkFactor,
                            vertical: Constants.padding * 0.425,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Share",
                          style: TextStyle(
                            fontSize: shrink ? Constants.smallFontSize : null,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
