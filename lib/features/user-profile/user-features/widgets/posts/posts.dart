import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/display/display_helper.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/widgets/carousel/custom_carousel_view.dart'
    as custom;
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/core/widgets/video-player/video_player.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Posts extends StatelessWidget {
  Posts({
    super.key,
    required this.postKey,
  });

  final String postKey;
  final UserGraph graph = UserGraph();

  @override
  Widget build(BuildContext context) {
    final PostEntity post = graph.getValueByKey(postKey)! as PostEntity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // post meta data
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              User(
                userKey: post.createdBy,
              ),
              Text(
                displayDateDifference(post.createdOn),
                style: const TextStyle(
                  fontSize: Constants.smallFontSize,
                ),
              ),
            ],
          ),
        ),
        // post content
        if (post.content.isNotEmpty) ...[
          const SizedBox(
            height: Constants.gap * 0.5,
          ),
          _PostContent(
            content: post.content,
          ),
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

class _PostContent extends StatelessWidget {
  _PostContent({
    required this.content,
  });

  final List<PostContentEntity> content;
  final custom.CarouselController controller = custom.CarouselController();

  Widget imageContent(PostContentEntity image) {
    return CachedNetworkImage(
      cacheKey: image.resource.bucketPath,
      fit: BoxFit.cover,
      imageUrl: image.resource.accessURI,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
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
      key: Key(video.resource.bucketPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = width * (1 / Constants.postContainer);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: custom.CustomCarouselView(
            controller: controller,
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
            children: content.map(
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
        if (content.length > 1)
          _PostContentIndicator(
            controller: controller,
            contentLength: content.length,
          ),
      ],
    );
  }
}

class _PostContentIndicator extends StatefulWidget {
  const _PostContentIndicator({
    required this.contentLength,
    required this.controller,
  });

  final int contentLength;
  final ScrollController controller;

  @override
  State<_PostContentIndicator> createState() => _PostContentIndicatorState();
}

class _PostContentIndicatorState extends State<_PostContentIndicator> {
  int activeItem = 0;
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;

    controller.addListener(() {
      int active = getActiveItem();
      if (active != activeItem) {
        safePrint("setting state");
        setState(() {
          activeItem = active;
        });
      }
    });
  }

  int getActiveItem() {
    double offset = controller.hasClients ? controller.offset : -1;
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 0.5;

    int item = (offset / width).round();

    return item;
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(
          height: Constants.gap,
        ),
        AnimatedSmoothIndicator(
          activeIndex: activeItem,
          count: widget.contentLength,
          effect: ScrollingDotsEffect(
            activeDotColor: currTheme.primary,
            dotWidth: Constants.carouselDots,
            dotHeight: Constants.carouselDots,
            activeDotScale: Constants.carouselActiveDotScale,
          ),
        ),
      ],
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
                      color: currTheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: Constants.smallFontSize,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() {
                          viewMore = !viewMore;
                        });
                      }),
              ]
            : [],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  _PostAction({
    required this.postId,
  }) : graphKey = generatePostNodeKey(postId);

  final String postId;
  final UserGraph graph = UserGraph();
  final String graphKey;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final String username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return BlocBuilder<UserActionBloc, UserActionState>(
      buildWhen: (previousState, state) {
        return (state is UserActionNodeActionState && state.nodeId == postId);
      },
      builder: (context, state) {
        PostEntity post = graph.getValueByKey(graphKey)! as PostEntity;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.padding,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "${displayNumberFormat(post.likesCount)} Like${post.likesCount > 1 ? "s" : ""}"),
                  Text(
                      "${displayNumberFormat(post.commentsCount)} Comment${post.commentsCount > 1 ? "s" : ""}"),
                ],
              ),
              const SizedBox(
                height: Constants.gap * 0.5,
              ),
              Container(
                height: Constants.height * 0.125,
                color: currTheme.surfaceContainerHighest,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context
                              .read<UserActionBloc>()
                              .add(UserActionPostLikeActionEvent(
                                postId: post.id,
                                userLike: !post.userLike,
                                username: username,
                              ));
                        },
                        icon: post.userLike
                            ? Icon(
                                Icons.thumb_up,
                                color: currTheme.primary,
                                size: Constants.iconButtonSize,
                              )
                            : const Icon(
                                Icons.thumb_up_outlined,
                                size: Constants.iconButtonSize,
                              ),
                      ),
                      const SizedBox(
                        width: Constants.gap,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Comment"),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: Constants.gap * 0.75,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Share"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
