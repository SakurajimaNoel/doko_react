import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    super.key,
    required this.commentKey,
  }) : isReply = false;

  const CommentWidget.reply({
    super.key,
    required this.commentKey,
  }) : isReply = true;

  final String commentKey;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final UserGraph graph = UserGraph();

    final commentId = generateCommentIdFromCommentKey(commentKey);
    final currTheme = Theme.of(context).colorScheme;

    final CommentEntity comment =
        graph.getValueByKey(commentKey)! as CommentEntity;

    final width = MediaQuery.sizeOf(context).width - Constants.padding * 3;
    final height = width / Constants.commentContainer;

    return _CommentWrapper(
      isReply: isReply,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              User.small(
                userKey: comment.commentBy,
                key: ValueKey(comment.id),
              ),
              Text(
                displayDateDifference(comment.createdOn),
                style: const TextStyle(
                  fontSize: Constants.smallFontSize * 0.9,
                ),
              ),
            ],
          ),
          if (comment.media.bucketPath.isNotEmpty) ...[
            SizedBox(
              height: Constants.gap * 0.5,
            ),
            Container(
              alignment: AlignmentDirectional.topStart,
              height: height,
              child: CachedNetworkImage(
                cacheKey: comment.media.bucketPath,
                fit: BoxFit.contain,
                imageUrl: comment.media.accessURI,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                filterQuality: FilterQuality.high,
                memCacheHeight: height.toInt(),
                height: height,
              ),
            )
          ],
          if (comment.content.isNotEmpty) ...[
            SizedBox(
              height: Constants.gap * 0.5,
            ),
            _CommentContent(
              content: comment.content,
            ),
          ],
          SizedBox(
            height: Constants.gap * 0.75,
          ),
          _CommentActions(
            commentId: commentId,
            isReply: isReply,
          ),
        ],
      ),
    );
  }
}

class _CommentWrapper extends StatelessWidget {
  const _CommentWrapper({
    required this.child,
    required this.isReply,
  });

  final Widget child;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    if (isReply) {
      return Container(
        margin: const EdgeInsets.only(
          left: Constants.padding,
        ),
        child: child,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.padding,
      ),
      padding: EdgeInsets.all(Constants.padding * 0.75),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.radius * 0.5),
        color: currTheme.surfaceContainer,
      ),
      child: child,
    );
  }
}

class _CommentContent extends StatefulWidget {
  const _CommentContent({required this.content});

  final List<String> content;

  @override
  State<_CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<_CommentContent> {
  late List<String> content = widget.content;
  late String stringContent = content.join("");

  bool viewMore = false;

  TextSpan buildComment() {
    final currTheme = Theme.of(context).colorScheme;
    final buttonText = viewMore ? "View less" : "View More";

    bool showButton =
        stringContent.length > Constants.commentContentDisplayLimit;

    // for view more
    int len = 0;
    List<TextSpan> children = [];

    for (int i = 0; i < content.length; i++) {
      String item = content[i];
      len += item.length;

      String itemAsUsername =
          item.length > 1 ? getUsernameFromCommentInput(item) : item;

      if (validateUsername(itemAsUsername)) {
        // valid mention
        children.add(
          TextSpan(
            text: item,
            style: TextStyle(
              color: currTheme.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.pushNamed(
                  RouterConstants.userProfile,
                  pathParameters: {
                    "username": itemAsUsername,
                  },
                );
              },
          ),
        );
      } else {
        children.add(
          TextSpan(
            text: item,
          ),
        );
      }

      if (!viewMore && len >= Constants.commentContentDisplayLimit) break;
    }

    if (showButton) {
      children.add(TextSpan(
        text: " $buttonText",
        style: TextStyle(
          color: currTheme.outline,
          fontWeight: FontWeight.w600,
          fontSize: Constants.smallFontSize,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            setState(() {
              viewMore = !viewMore;
            });
          },
      ));
    }

    return TextSpan(
      style: TextStyle(
        color: currTheme.onSurface,
      ),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: buildComment(),
    );
  }
}

class _CommentActions extends StatefulWidget {
  const _CommentActions({
    required this.commentId,
    required this.isReply,
  });

  final String commentId;
  final bool isReply;

  @override
  State<_CommentActions> createState() => _CommentActionsState();
}

class _CommentActionsState extends State<_CommentActions>
    with SingleTickerProviderStateMixin {
  final UserGraph graph = UserGraph();

  late final String commentId = widget.commentId;
  late final String commentKey = generateCommentNodeKey(commentId);
  late final String username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  late final AnimationController controller = AnimationController(
    duration: const Duration(
      milliseconds: 200,
    ),
    vsync: this,
    value: 1.0,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommentEntity comment =
        graph.getValueByKey(commentKey)! as CommentEntity;

    final currTheme = Theme.of(context).colorScheme;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return state is UserActionNodeActionState && state.nodeId == commentId;
      },
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween(begin: 1.25, end: 1.0).animate(
                    CurvedAnimation(
                      parent: controller,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (!comment.userLike) {
                        controller
                            .reverse()
                            .then((value) => controller.forward());
                      }

                      context
                          .read<UserActionBloc>()
                          .add(UserActionCommentLikeActionEvent(
                            commentId: comment.id,
                            userLike: !comment.userLike,
                            username: username,
                          ));
                    },
                    child: comment.userLike
                        ? Icon(
                            Icons.thumb_up,
                            color: currTheme.primary,
                            size: Constants.iconButtonSize * 0.75,
                          )
                        : Icon(
                            Icons.thumb_up_outlined,
                            color: currTheme.secondary,
                            size: Constants.iconButtonSize * 0.75,
                          ),
                  ),
                ),
                const SizedBox(
                  width: Constants.gap * 0.5,
                ),
                Text(displayNumberFormat(comment.likesCount)),
                const SizedBox(
                  width: Constants.gap * 2,
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Reply",
                    style: TextStyle(
                      color: currTheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              "${displayNumberFormat(comment.commentsCount)} Repl${comment.commentsCount > 1 ? "ies" : "y"}",
              style: TextStyle(
                color: currTheme.onSurfaceVariant,
                fontSize: Constants.smallFontSize * 0.9,
              ),
            ),
          ],
        );
      },
    );
  }
}
