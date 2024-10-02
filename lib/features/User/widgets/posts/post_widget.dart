import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/widgets/error_text.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/widgets/posts/post_user_widget.dart';
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
    var height = contentWidth * 3 / 4;

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
            child: Text(post.caption),
          ),
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          // const _PostAction(),
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
    return Container(
      color: Colors.deepPurple,
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

    return CarouselView(
      itemExtent: contentWidth,
      shrinkExtent: contentWidth * 0.5,
      itemSnapping: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.padding * 0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(Constants.radius),
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

// post actions
class _PostAction extends StatelessWidget {
  const _PostAction();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
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
      ],
    );
  }
}
