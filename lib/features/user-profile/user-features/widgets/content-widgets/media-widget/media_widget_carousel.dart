part of "media_widget.dart";

class _MediaContent extends StatefulWidget {
  const _MediaContent({
    required this.nodeKey,
  });

  final String nodeKey;

  @override
  State<_MediaContent> createState() => _MediaContentState();
}

class _MediaContentState extends State<_MediaContent> {
  late final CarouselController controller;

  final UserGraph graph = UserGraph();
  late final String nodeKey = widget.nodeKey;

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

  int getCurrentCarouselItem() {
    double offset = controller.hasClients ? controller.offset : -1;
    double width = context.read<MediaCarouselIndicatorProvider>().width;

    return (offset / width).round();
  }

  void updateCurrentItem() {
    int item = getCurrentCarouselItem();

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
    final currTheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: currTheme.surfaceContainer,
      ),
      child: CachedNetworkImage(
        cacheKey: image.resource.bucketPath,
        fit: BoxFit.cover,
        imageUrl: image.resource.accessURI,
        placeholder: (context, url) => const Center(
          child: LoadingWidget.small(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final mediaEntity =
        graph.getValueByKey(nodeKey)! as UserActionEntityWithMediaItems;

    List<MediaEntity> displayItems = mediaEntity.mediaItems;

    String currentRoute = GoRouter.of(context).currentRouteName ?? "";
    bool isArchivePage = currentRoute == RouterConstants.messageArchive;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * (1 / Constants.contentContainer);

        return Column(
          spacing: Constants.gap * 0.5,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: CarouselView(
                onTap: isArchivePage
                    ? null
                    : (index) {
                        context.pushNamed(
                          RouterConstants.mediaCarousel,
                          pathParameters: {
                            "nodeKey": nodeKey,
                          },
                        );
                      },
                enableSplash: false,
                controller: controller,
                itemExtent: width,
                shrinkExtent: width * 0.5,
                itemSnapping: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Constants.radius,
                  ),
                ),
                children: displayItems.map(
                  (item) {
                    Widget child;
                    switch (item.mediaType) {
                      case MediaTypeValue.image:
                        child = imageContent(item);
                      case MediaTypeValue.video:
                        child = videoContent(item);
                      default:
                        child = unknownContent(item);
                    }

                    return child;
                  },
                ).toList(),
              ),
            ),
            if (mediaEntity.mediaItems.length > 1)
              Builder(
                builder: (context) {
                  final currItem = context.select(
                      (MediaCarouselIndicatorProvider provider) =>
                          provider.currentItem);

                  return AnimatedSmoothIndicator(
                    activeIndex: currItem,
                    count: mediaEntity.mediaItems.length,
                    effect: ScrollingDotsEffect(
                      activeDotColor: currTheme.primary,
                      dotWidth: Constants.carouselDots,
                      dotHeight: Constants.carouselDots,
                      activeDotScale: Constants.carouselActiveDotScale,
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
