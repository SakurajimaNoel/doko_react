import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/widgets/error/error_text.dart';
import 'package:doko_react/core/widgets/general/custom_carousel_view.dart'
    as custom;
import 'package:doko_react/core/widgets/video_player/video_player.dart';
import 'package:doko_react/features/User/Profile/widgets/user/user_widget.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final PostModel post;
  final ValueChanged<bool> handlePostLike;

  const PostWidget({
    super.key,
    required this.post,
    required this.handlePostLike,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = width * (1 / Constants.postContainer);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: Constants.gap * 1.25),
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
                UserWidget(
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
            SizedBox(
              // content carousel
              height: height,
              width: width,
              child: _PostContent(
                content: post.content,
                id: post.id,
              ),
            ),
          ],
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          // caption
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.padding,
              vertical: Constants.padding * 0.5,
            ),
            child: _PostCaption(caption: post.caption),
          ),
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.padding,
            ),
            child: _PostAction(
              postModel: post,
              likeAction: handlePostLike,
            ),
          ),
        ],
      ),
    );
  }
}

// post content carousel view
class _PostContent extends StatefulWidget {
  final List<Content> content;
  final String id;

  const _PostContent({
    required this.content,
    required this.id,
  });

  @override
  State<_PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<_PostContent> {
  final custom.CarouselController carouselController =
      custom.CarouselController();

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
      key: Key(item.key),
    );
  }

  Widget _handleUnknownContent(Content item) {
    return const Center(
      child: ErrorText("Oops! Something went wrong."),
    );
  }

  @override
  void dispose() {
    safePrint("widget disposed");
    safePrint(carouselController);

    carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    return custom.CustomCarouselView(
      controller: carouselController,
      itemExtent: width,
      shrinkExtent: width * 0.5,
      itemSnapping: true,
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.padding * 0.25,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(Constants.radius * 0.25),
        ),
      ),
      children: widget.content.map(
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
class _PostAction extends StatefulWidget {
  final PostModel postModel;
  final ValueChanged<bool> likeAction;

  const _PostAction({
    required this.postModel,
    required this.likeAction,
  });

  @override
  State<_PostAction> createState() => _PostActionState();
}

class _PostActionState extends State<_PostAction> {
  final UserGraphqlService _userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );

  late final PostModel _post;
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    _post = widget.postModel;
  }

  Future<void> handleLike() async {
    bool likeStatus = _post.userLike;

    setState(() {
      _updating = true;
      _post.updateUserLike(!likeStatus); // for widget state
    });

    var likeResponse = await _userGraphqlService.userLikePostAction(
      postId: _post.id,
      addLike: _post.userLike,
    );

    setState(() {
      _updating = false;
    });

    if (likeResponse == ResponseStatus.error) {
      setState(() {
        _post.updateUserLike(likeStatus);
      });
    }

    widget.likeAction(!likeStatus);
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    List<Widget> actionChildren = [
      GestureDetector(
        onTap: _updating ? null : handleLike,
        child: _post.userLike
            ? Icon(
                Icons.thumb_up,
                color: currTheme.primary,
              )
            : const Icon(Icons.thumb_up_outlined),
      ),
      const SizedBox(
        width: Constants.gap * 0.5,
      ),
      Text(DisplayText.displayNumericValue(_post.likes)),
      const SizedBox(
        width: Constants.gap * 1.5,
      ),
      GestureDetector(
        onTap: () {},
        child: const Icon(Icons.insert_comment_outlined),
      ),
      const SizedBox(
        width: Constants.gap * 0.5,
      ),
      Text(DisplayText.displayNumericValue(_post.comments)),
      const SizedBox(
        width: Constants.gap * 1.5,
      ),
      GestureDetector(
        onTap: () {},
        child: const Icon(Icons.share),
      )
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: actionChildren,
    );
  }
}
