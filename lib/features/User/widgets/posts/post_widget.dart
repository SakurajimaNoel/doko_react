import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/general/custom_carousel_view.dart';
import 'package:doko_react/core/widgets/video_player/video_player.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/widgets/posts/post_user_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final PostModel post;

  const PostWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    var contentWidth =
        width - (Constants.actionWidth + Constants.actionEdgeGap);
    var height = contentWidth * (1 / Constants.postContainer);

    return Container(
      margin: const EdgeInsets.only(bottom: Constants.gap * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // post metadata
            padding: const EdgeInsets.symmetric(horizontal: Constants.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PostUserWidget(
                  user: post.createdBy,
                ),
                Text(
                  DisplayText.displayDateDiff(post.createdOn),
                  style: const TextStyle(
                    fontSize: Constants.smallFontSize,
                  ),
                ),
              ],
            ),
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(
              height: Constants.gap * 0.5,
            ),
            Row(
              children: [
                SizedBox(
                  // content carousel
                  height: height,
                  width: contentWidth,
                  child: _PostContent(
                    content: post.content,
                  ),
                ),
                SizedBox(
                  // post action
                  height: height,
                  width: Constants.actionWidth,
                  child: const _PostAction(),
                ),
                const SizedBox(
                  // gap from edge
                  width: Constants.actionEdgeGap,
                ),
              ],
            ),
          ],
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          // caption
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.padding,
            ),
            child: _PostCaption(caption: post.caption),
          ),
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          if (post.content.isEmpty)
            const _PostAction(
              row: true,
            ),
        ],
      ),
    );
  }
}

// post content carousel view
class _PostContent extends StatelessWidget {
  final List<Content> content;

  const _PostContent({
    required this.content,
  });

  Widget _handleImageContent(Content item) {
    return CachedNetworkImage(
      cacheKey: item.key,
      fit: BoxFit.cover,
      imageUrl: item.signedURL,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      filterQuality: FilterQuality.high,
      memCacheHeight: Constants.postCacheHeight,
    );
  }

  Widget _handleVideoContent(Content item) {
    return VideoPlayer(
      path: item.signedURL,
      autoplay: false,
      key: Key(item.key),
    );
  }

  Widget _handleUnknownContent(Content item) {
    return const Center(
      child: ErrorText("Oops! Something went wrong."),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    var contentWidth =
        width - (Constants.actionWidth + Constants.actionEdgeGap);

    return CustomCarouselView(
      itemExtent: contentWidth,
      shrinkExtent: contentWidth * 0.5,
      itemSnapping: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.padding * 0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(Constants.radius * 0.5),
        ),
      ),
      children: content.map(
        (item) {
          switch (item.mediaType) {
            case MediaTypeValue.image:
              return _handleImageContent(item);
            case MediaTypeValue.video:
              return _handleVideoContent(item);
            default:
              return _handleUnknownContent(item);
          }
        },
      ).toList(),
    );
  }
}

// post caption
class _PostCaption extends StatefulWidget {
  final String caption;

  const _PostCaption({
    required this.caption,
  });

  @override
  State<_PostCaption> createState() => _PostCaptionState();
}

class _PostCaptionState extends State<_PostCaption> {
  bool _viewMore = false;

  @override
  Widget build(BuildContext context) {
    var displayText = _viewMore
        ? widget.caption
        : DisplayText.trimText(
            widget.caption,
            len: Constants.postCaptionDisplayLimit,
          );

    var buttonText = _viewMore ? "View less" : "View More";
    bool showButton = widget.caption.length > Constants.postCaptionDisplayLimit;
    var currTheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: currTheme.onSurface,
          fontSize: Constants.fontSize,
        ),
        children: showButton
            ? [
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
                          _viewMore = !_viewMore;
                        });
                      }),
              ]
            : [],
      ),
    );
  }
}

// post actions
class _PostAction extends StatelessWidget {
  final bool row;

  const _PostAction({
    this.row = false,
  });

  Widget _actionAlignment(List<Widget> actionChildren) {
    if (row) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textDirection: TextDirection.rtl,
        children: actionChildren,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actionChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionChildren = [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.share),
        iconSize: Constants.width * 1.25,
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.insert_comment_outlined),
        iconSize: Constants.width * 1.25,
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.thumb_up_alt_outlined),
        iconSize: Constants.width * 1.25,
      ),
    ];

    return _actionAlignment(actionChildren);
  }
}
