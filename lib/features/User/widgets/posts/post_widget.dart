import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/widgets/posts/post_user_widget.dart';
import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final PostModel post;
  final String? profileImage;

  const PostWidget({
    super.key,
    required this.post,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
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
                  profileImg: profileImage,
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
                  height: Constants.height * 16,
                  width: MediaQuery.of(context).size.width * 0.9 - 2,
                  child: _PostContentCarouseView(
                    content: post.content,
                    signedContent: post.signedContent,
                  ),
                ),
                SizedBox(
                  height: Constants.height * 16,
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: const _PostAction(),
                ),
                const SizedBox(
                  width: Constants.gap * 0.125,
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
class _PostContentCarouseView extends StatelessWidget {
  final List<String> content;
  final List<String> signedContent;

  const _PostContentCarouseView({
    super.key,
    required this.content,
    required this.signedContent,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselView(
      itemExtent: MediaQuery.of(context).size.width * 0.9 - 2,
      shrinkExtent: Constants.width * 10,
      itemSnapping: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.padding * 0.5,
      ),
      children: signedContent.map(
        (item) {
          int index = signedContent.indexOf(item);
          String cacheKey = content[index];

          return CachedNetworkImage(
            cacheKey: cacheKey,
            fit: BoxFit.cover,
            imageUrl: item,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            // height: double.infinity,
            filterQuality: FilterQuality.high,
            memCacheHeight: Constants.postCacheHeight,
          );
        },
      ).toList(),
    );
  }
}

// post content
class _PostContent extends StatelessWidget {
  final List<String> content;
  final List<String> signedContent;

  const _PostContent({
    super.key,
    required this.content,
    required this.signedContent,
  });

  Widget _postContentItem(BuildContext context, int index) {
    return SizedBox(
      height: double.infinity,
      width: MediaQuery.of(context).size.width * 0.9 - 2,
      child: signedContent[index].isEmpty
          ? const Center(
              child: Icon(Icons.error),
            )
          : CachedNetworkImage(
              cacheKey: content[index],
              fit: BoxFit.cover,
              imageUrl: signedContent[index],
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              // height: Constants.height * 20,
              height: double.infinity,
              filterQuality: FilterQuality.high,
              memCacheHeight: Constants.postCacheHeight,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      itemCount: content.length,
      itemBuilder: (BuildContext context, int index) =>
          _postContentItem(context, index),
    );
  }
}

// post actions
class _PostAction extends StatelessWidget {
  const _PostAction({super.key});

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
