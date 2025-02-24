import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/core/widgets/video-player/video_player.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/media/media_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/media-widget/provider/media_carousel_indicator_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MediaWidget extends StatelessWidget {
  const MediaWidget({
    super.key,
    required this.mediaItems,
    required this.nodeKey,
    this.width,
  }) : preview = false;

  const MediaWidget.preview({
    super.key,
    required this.mediaItems,
    required this.nodeKey,
    this.width,
  }) : preview = true;

  final List<MediaEntity> mediaItems;
  final bool preview;
  final String nodeKey;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final graph = UserGraph();
    final node = graph.getValueByKey(nodeKey);

    if (node is! UserActionEntityWithMediaItems) {
      return const SizedBox(
        height: Constants.height * 5,
        child: Center(
          child: StyledText.error(Constants.errorMessage),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = width ?? constraints.maxWidth;

        return ChangeNotifierProvider(
          create: (_) => MediaCarouselIndicatorProvider(
            currentItem: node.currDisplay,
            width: maxWidth,
          ),
          child: _MediaContent(
            content: mediaItems,
            preview: preview,
            nodeKey: nodeKey,
          ),
        );
      },
    );
  }
}

class _MediaContent extends StatefulWidget {
  const _MediaContent({
    required this.content,
    required this.preview,
    required this.nodeKey,
  });

  final List<MediaEntity> content;
  final bool preview;
  final String nodeKey;

  @override
  State<_MediaContent> createState() => _MediaContentState();
}

class _MediaContentState extends State<_MediaContent> {
  late final CarouselController controller;
  late final preview = widget.preview;

  final UserGraph graph = UserGraph();
  late final String nodeKey = widget.nodeKey;

  bool boxFitContain = false;

  @override
  void initState() {
    super.initState();

    final node =
        graph.getValueByKey(nodeKey)! as UserActionEntityWithMediaItems;

    controller = CarouselController(
      initialItem: node.currDisplay,
    );
    controller.addListener(updateCurrentItem);
  }

  void updateCurrentItem() {
    double offset = controller.hasClients ? controller.offset : -1;
    double width = context.read<MediaCarouselIndicatorProvider>().width;

    int item = (offset / width).round();

    final node =
        graph.getValueByKey(nodeKey)! as UserActionEntityWithMediaItems;
    node.updateDisplayItem(item);

    context.read<MediaCarouselIndicatorProvider>().updateCurrentItem(item);
  }

  @override
  void dispose() {
    controller.removeListener(updateCurrentItem);
    controller.dispose();

    super.dispose();
  }

  Widget imageContent(MediaEntity image) {
    return GestureDetector(
      onTap: () {
        setState(() {
          boxFitContain = !boxFitContain;
        });
      },
      child: CachedNetworkImage(
        cacheKey: image.resource.bucketPath,
        fit: boxFitContain ? BoxFit.contain : BoxFit.cover,
        imageUrl: image.resource.accessURI,
        placeholder: (context, url) => const Center(
          child: SmallLoadingIndicator.small(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        filterQuality: FilterQuality.high,
        memCacheHeight: Constants.postCacheHeight,
      ),
    );
  }

  Widget unknownContent(MediaEntity item) {
    return const Center(
      child: StyledText.error(Constants.errorMessage),
    );
  }

  Widget videoContent(MediaEntity video) {
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
                      (MediaCarouselIndicatorProvider provider) =>
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
