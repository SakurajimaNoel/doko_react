import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/archive/core/configs/router/router_constants.dart';
import 'package:doko_react/archive/core/helpers/constants.dart';
import 'package:doko_react/archive/core/helpers/display.dart';
import 'package:doko_react/archive/core/helpers/input.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/features/User/Profile/widgets/user/user_widget.dart';
import 'package:doko_react/archive/features/User/data/model/comment_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CommentWidget extends StatelessWidget {
  final CommentModel comment;
  final ValueChanged<bool> handleCommentLike;
  final VoidCallback handleReply;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.handleCommentLike,
    required this.handleReply,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final commentMediaHeight = width / Constants.commentContainer;
    // final currTheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserWidget(
                user: comment.commentBy,
              ),
              Text(
                DisplayText.displayDateDiff(comment.createdOn),
                style: const TextStyle(
                  fontSize: Constants.smallFontSize,
                ),
              ),
            ],
          ),
        ),
        if (comment.media.isNotEmpty) ...[
          const SizedBox(
            height: Constants.gap,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.padding,
            ),
            width: double.infinity,
            // height: commentMediaHeight,
            child: CachedNetworkImage(
              cacheKey: comment.media,
              fit: BoxFit.contain,
              imageUrl: comment.signedMedia,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              filterQuality: FilterQuality.high,
              memCacheHeight: commentMediaHeight.toInt(),
              height: commentMediaHeight,
            ),
          ),
        ],
        if (comment.content.isNotEmpty) ...[
          const SizedBox(
            height: Constants.gap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.padding,
            ),
            child: _CommentContent(
              content: comment.content,
            ),
          ),
        ],
        const SizedBox(
          height: Constants.gap,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          child: _CommentActions(
            comment: comment,
            likeAction: handleCommentLike,
            handleReply: handleReply,
          ),
        ),
      ],
    );
  }
}

class _CommentContent extends StatefulWidget {
  final List<String> content;

  const _CommentContent({
    required this.content,
  });

  @override
  State<_CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<_CommentContent> {
  bool viewMore = false;
  late String stringContent;

  @override
  void initState() {
    super.initState();

    stringContent = widget.content.join("");
  }

  TextSpan buildComment() {
    var currTheme = Theme.of(context).colorScheme;
    var buttonText = viewMore ? "View less" : "View More";
    bool showButton =
        stringContent.length > Constants.commentContentDisplayLimit;

    int len = 0;
    List<TextSpan> children = [];
    for (int i = 0; i < widget.content.length; i++) {
      String item = widget.content[i];
      len += item.length;
      String itemAsUsername = item.length > 1
          ? DisplayText.getUsernameFromCommentInput(item)
          : item;

      if (ValidateInput.validateUsername(itemAsUsername).isValid) {
        // is username
        children.add(
          TextSpan(
            text: item,
            style: TextStyle(
              color: currTheme.primary,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.pushNamed(RouterConstants.userProfile, pathParameters: {
                  "username": itemAsUsername,
                });
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
      children.add(
        TextSpan(
          text: " $buttonText",
          style: TextStyle(
            color: currTheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: Constants.smallFontSize,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              setState(() {
                viewMore = !viewMore;
              });
            },
        ),
      );
    }

    return TextSpan(
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
  final CommentModel comment;
  final ValueChanged<bool> likeAction;
  final VoidCallback handleReply;

  const _CommentActions({
    required this.comment,
    required this.likeAction,
    required this.handleReply,
  });

  @override
  State<_CommentActions> createState() => _CommentActionsState();
}

class _CommentActionsState extends State<_CommentActions> {
  late final UserProvider userProvider;

  // final UserGraphqlService _userGraphqlService = UserGraphqlService(
  //   client: GraphqlConfig.getGraphQLClient(),
  // );
  bool updating = false;

  @override
  void initState() {
    super.initState();

    userProvider = context.read<UserProvider>();
  }

  Future<void> handleLike() async {
    bool likeStatus = widget.comment.userLike;

    setState(() {
      updating = true;
      widget.comment.updateUserLike(!likeStatus); // for widget state
    });

    // var likeResponse = await _userGraphqlService.userLikePostAction(
    //   _post.id,
    //   addLike: _post.userLike,
    //   username: userProvider.username,
    // );

    setState(() {
      updating = false;
    });

    // if (likeResponse == ResponseStatus.error) {
    //   setState(() {
    //     widget.comment.updateUserLike(likeStatus);
    //   });
    // }

    widget.likeAction(!likeStatus);
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    List<Widget> actionChildren = [
      GestureDetector(
        onTap: updating ? null : handleLike,
        child: widget.comment.userLike
            ? Icon(
                Icons.thumb_up,
                color: currTheme.primary,
                size: 16,
              )
            : const Icon(
                Icons.thumb_up_outlined,
                size: 16,
              ),
      ),
      const SizedBox(
        width: Constants.gap * 0.5,
      ),
      Text(DisplayText.displayNumericValue(widget.comment.likes)),
      const SizedBox(
        width: Constants.gap * 1.5,
      ),
      GestureDetector(
        onTap: () {
          widget.handleReply();
        },
        child: const Text("Reply"),
      ),
      const Spacer(),
      Text(
          "${DisplayText.displayNumericValue(widget.comment.comments)} ${widget.comment.comments > 1 ? "replies" : "reply"}."),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: actionChildren,
    );
  }
}
