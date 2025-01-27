import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/display/display_helper.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/widgets/like-widget/like_widget.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/share/share.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/core/widgets/video-player/video_player.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/provider/post_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/posts/provider/post_carousel_indicator_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.postKey,
  });

  final String postKey;

  @override
  Widget build(BuildContext context) {
    final UserGraph graph = UserGraph();
    final PostEntity post = graph.getValueByKey(postKey)! as PostEntity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // post meta data
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            bool shrink = constraints.maxWidth < Constants.postMetadataWidth;
            double shrinkFactor = shrink ? 0.75 : 1;

            bool superShrink = constraints.maxWidth < 250;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!shrink)
                  UserWidget(
                    userKey: post.createdBy,
                  )
                else
                  UserWidget.small(
                    key: ValueKey("${post.createdBy}-with-small-size"),
                    userKey: post.createdBy,
                  ),
                if (!superShrink)
                  Text(
                    displayDateDifference(
                      post.createdOn,
                      small: shrink,
                    ),
                    style: TextStyle(
                      fontSize: Constants.smallFontSize * shrinkFactor,
                    ),
                  ),
              ],
            );
          }),
        ),
        // post content
        if (post.content.isNotEmpty) ...[
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            return ChangeNotifierProvider(
              create: (_) => PostCarouselIndicatorProvider(
                currentItem: 0,
                width: width,
              ),
              child: PostContent(
                content: post.content,
              ),
            );
          }),
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
        ],
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
            vertical: Constants.padding * 0.5,
          ),
          child: _PostCaption(
            caption: post.caption,
          ),
        ),
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        _PostAction(
          postId: post.id,
        ),
      ],
    );
  }
}

// [PostContent] should always have a parent with [PostCarouselIndicatorProvider]
class PostContent extends StatefulWidget {
  const PostContent({
    super.key,
    required this.content,
  }) : preview = false;

  const PostContent.preview({
    super.key,
    required this.content,
  }) : preview = true;

  final List<PostContentEntity> content;
  final bool preview;

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  final CarouselController controller = CarouselController();
  late final preview = widget.preview;

  @override
  void initState() {
    super.initState();

    controller.addListener(updateCurrentItem);
  }

  void updateCurrentItem() {
    double offset = controller.hasClients ? controller.offset : -1;
    double width = context.read<PostCarouselIndicatorProvider>().width;

    int item = (offset / width).round();

    context.read<PostCarouselIndicatorProvider>().updateCurrentItem(item);
  }

  @override
  void dispose() {
    controller.removeListener(updateCurrentItem);
    controller.dispose();

    super.dispose();
  }

  Widget imageContent(PostContentEntity image) {
    return CachedNetworkImage(
      cacheKey: image.resource.bucketPath,
      fit: BoxFit.cover,
      imageUrl: image.resource.accessURI,
      placeholder: (context, url) => const Center(
        child: SmallLoadingIndicator.small(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      filterQuality: FilterQuality.high,
      memCacheHeight: Constants.postCacheHeight,
    );
  }

  Widget unknownContent(PostContentEntity item) {
    return const Center(
      child: StyledText.error(Constants.errorMessage),
    );
  }

  Widget videoContent(PostContentEntity video) {
    return VideoPlayer(
      path: video.resource.accessURI,
      bucketPath: video.resource.bucketPath,
      // key: Key(video.resource.bucketPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * (1 / Constants.postContainer);

        context.read<PostCarouselIndicatorProvider>().updateWidth(width);

        return Column(
          spacing: Constants.gap * (preview ? 0.75 : 1),
          children: [
            SizedBox(
              height: height,
              child: CarouselView(
                enableSplash: false,
                controller: controller,
                itemExtent: width,
                shrinkExtent: width * 0.5,
                itemSnapping: true,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      Constants.padding * (widget.preview ? 0.15 : 0.25),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Constants.radius * (widget.preview ? 1 : 0.25),
                  ),
                ),
                children: widget.content.map(
                  (item) {
                    switch (item.mediaType) {
                      case MediaTypeValue.image:
                        return imageContent(item);
                      case MediaTypeValue.video:
                        return videoContent(item);
                      default:
                        return unknownContent(item);
                    }
                  },
                ).toList(),
              ),
            ),
            if (widget.content.length > 1)
              Builder(
                builder: (context) {
                  final currItem = context.select(
                      (PostCarouselIndicatorProvider provider) =>
                          provider.currentItem);

                  return AnimatedSmoothIndicator(
                    activeIndex: currItem,
                    count: widget.content.length,
                    effect: ScrollingDotsEffect(
                      activeDotColor: currTheme.primary,
                      dotWidth:
                          Constants.carouselDots * (widget.preview ? 0.75 : 1),
                      dotHeight:
                          Constants.carouselDots * (widget.preview ? 0.75 : 1),
                      activeDotScale: Constants.carouselActiveDotScale *
                          (widget.preview ? 0.75 : 1),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _PostCaption extends StatefulWidget {
  const _PostCaption({required this.caption});

  final String caption;

  @override
  State<_PostCaption> createState() => _PostCaptionState();
}

class _PostCaptionState extends State<_PostCaption> {
  bool viewMore = false;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    String displayCaption = viewMore
        ? widget.caption
        : trimText(
            widget.caption,
            len: Constants.postCaptionDisplayLimit,
          );

    bool showButton = widget.caption.length > Constants.postCaptionDisplayLimit;
    String buttonText = viewMore ? "View less" : "View More";

    return RichText(
      text: TextSpan(
        text: displayCaption,
        style: TextStyle(
          color: currTheme.onSurface,
          fontSize: Constants.fontSize,
        ),
        children: showButton
            ? [
                TextSpan(
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
                ),
              ]
            : [],
      ),
    );
  }
}

class _PostAction extends StatefulWidget {
  _PostAction({
    required this.postId,
  }) : graphKey = generatePostNodeKey(postId);

  final String postId;
  final String graphKey;

  @override
  State<_PostAction> createState() => _PostActionState();
}

class _PostActionState extends State<_PostAction> {
  final UserGraph graph = UserGraph();

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final String username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionNodeActionState &&
                state.nodeId == widget.postId) ||
            (state is UserActionPostRefreshState &&
                state.nodeId == widget.postId);
      },
      builder: (context, state) {
        PostEntity post = graph.getValueByKey(widget.graphKey)! as PostEntity;

        return LayoutBuilder(
          builder: (context, constraints) {
            bool shrink = constraints.maxWidth < 285;
            bool superShrink = constraints.maxWidth < 235;

            double shrinkFactor = shrink
                ? 0.75
                : superShrink
                    ? 0.5
                    : 1;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.padding * shrinkFactor,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${displayNumberFormat(post.likesCount)} Like${post.likesCount > 1 ? "s" : ""}",
                        style: TextStyle(
                          fontSize:
                              superShrink ? Constants.smallFontSize : null,
                        ),
                      ),
                      Text(
                        "${displayNumberFormat(post.commentsCount)} Comment${post.commentsCount > 1 ? "s" : ""}",
                        style: TextStyle(
                          fontSize:
                              superShrink ? Constants.smallFontSize : null,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: Constants.dividerThickness * 0.75,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing:
                        Constants.gap * shrinkFactor - (superShrink ? 0.9 : 0),
                    children: [
                      Row(
                        spacing: Constants.gap * shrinkFactor -
                            (superShrink ? 0.9 : 0),
                        children: [
                          LikeWidget(
                            shrinkFactor: shrinkFactor,
                            onPress: () {
                              context
                                  .read<UserActionBloc>()
                                  .add(UserActionPostLikeActionEvent(
                                    postId: post.id,
                                    userLike: !post.userLike,
                                    username: username,
                                  ));
                            },
                            userLike: post.userLike,
                          ),
                          TextButton(
                            onPressed: () {
                              String currentRoute =
                                  GoRouter.of(context).currentRouteName ?? "";
                              bool isPostPage =
                                  currentRoute == RouterConstants.userPost;

                              if (isPostPage) {
                                context.read<PostCommentProvider>()
                                  ..focusNode.requestFocus()
                                  ..resetCommentTarget();
                                return;
                              }

                              context.pushNamed(
                                RouterConstants.userPost,
                                pathParameters: {
                                  "postId": post.id,
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: currTheme.secondary,
                              minimumSize: Size.zero,
                              padding: EdgeInsets.symmetric(
                                horizontal: Constants.padding * shrinkFactor,
                                vertical: Constants.padding * 0.5,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Comment",
                              style: TextStyle(
                                fontSize: superShrink
                                    ? Constants.smallFontSize
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Share.share(
                            context: context,
                            subject: MessageSubject.dokiPost,
                            nodeIdentifier: post.id,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: currTheme.secondary,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                            horizontal: Constants.padding * shrinkFactor,
                            vertical: Constants.padding * 0.5,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Share",
                          style: TextStyle(
                            fontSize:
                                superShrink ? Constants.smallFontSize : null,
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
