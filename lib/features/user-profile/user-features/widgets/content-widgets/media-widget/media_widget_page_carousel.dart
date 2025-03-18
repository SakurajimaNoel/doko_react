part of "media_widget.dart";

/// [https://github.dev/LuuNgocLan/flutter-snippets/blob/interactive_gallery/interactive_gallery/lib/preview_image_gallery.dart]
/// copied from above link
/// [https://medium.com/@lanltn/flutter-interactive-viewer-gallery-with-interactiveviewer-55ae260d2014]
/// medium article for this
class _MediaContentPage extends StatefulWidget {
  const _MediaContentPage({
    required this.nodeKey,
  })  : minScale = 1,
        maxScale = 5;

  final String nodeKey;
  final double minScale;
  final double maxScale;

  @override
  State<_MediaContentPage> createState() => _MediaContentPageState();
}

class _MediaContentPageState extends State<_MediaContentPage>
    with TickerProviderStateMixin {
  late final PageController controller;

  final UserGraph graph = UserGraph();
  late final String nodeKey = widget.nodeKey;

  bool shouldScroll = true;

  final TransformationController transformationController =
      TransformationController();
  double get scale => transformationController.value.row0.x;

  /// Handle double tap to zoom in/out
  late Offset _doubleTapLocalPosition;

  /// The controller to animate the transformation value of the
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  /// For handle drag to pop action
  late final AnimationController _dragAnimationController;

  /// Drag offset animation controller.
  late Animation<Offset> _dragAnimation;
  Offset? _dragOffset;
  Offset? _previousPosition;

  /// Flag to enabled/disabled drag to pop action
  bool _enableDrag = true;

  /// Animate hide bar
  late final AnimationController _hidePercentController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  final bool _isTapScreen = false;

  @override
  void initState() {
    super.initState();

    final node =
        graph.getValueByKey(nodeKey)! as UserActionEntityWithMediaItems;

    controller = PageController(
      initialPage: node.currDisplay,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        transformationController.value =
            _animation?.value ?? Matrix4.identity();
      });

    /// initial drag animation controller
    _dragAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        _onAnimationEnd(status);
      });
    _dragAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_dragAnimationController);

    /// initial hide bar animation
    _hidePercentController.addListener(() {
      if (_hidePercentController.status == AnimationStatus.dismissed) {
        _delayHideMenu();
      }
    });
  }

  Future _delayHideMenu() async {
    if (_isTapScreen) return;
    await _hidePercentController.forward();
  }

  void _onAnimationEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _dragAnimationController.reset();
      setState(() {
        _dragOffset = null;
        _previousPosition = null;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    transformationController.dispose();
    _hidePercentController.dispose();
    _dragAnimationController.removeStatusListener(_onAnimationEnd);
    _dragAnimationController.dispose();
    _animationController.dispose();

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
        fit: BoxFit.contain,
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
      fullScreen: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final mediaEntity =
        graph.getValueByKey(nodeKey)! as UserActionEntityWithMediaItems;

    List<MediaEntity> displayItems = mediaEntity.mediaItems;

    return AnimatedBuilder(
      builder: (context, Widget? child) {
        Offset finalOffset = _dragOffset ?? const Offset(0.0, 0.0);
        if (_dragAnimation.status == AnimationStatus.forward) {
          finalOffset = _dragAnimation.value;
        }
        return Transform.translate(
          offset: finalOffset,
          child: child,
        );
      },
      animation: _dragAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight - Constants.height * 0.5;

          return Stack(
            children: [
              SizedBox(
                height: height,
                child: PageView.builder(
                  physics: shouldScroll
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  controller: controller,
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) {
                    MediaEntity item = displayItems[index];

                    Widget child;
                    switch (item.mediaType) {
                      case MediaTypeValue.image:
                        child = imageContent(item);
                      case MediaTypeValue.video:
                        child = videoContent(item);
                      default:
                        child = unknownContent(item);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Constants.radius),
                      ),
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.symmetric(
                        horizontal: Constants.padding * 0.25,
                      ),
                      child: InteractiveViewer(
                        transformationController: transformationController,
                        minScale: widget.minScale,
                        maxScale: widget.maxScale,
                        onInteractionUpdate: (details) {
                          _onDragUpdate(details);
                          if (scale == 1) {
                            _enableDrag = true;
                            shouldScroll = true;
                          } else {
                            _enableDrag = false;
                            shouldScroll = false;
                          }

                          setState(() {});
                        },
                        onInteractionEnd: (details) {
                          if (_enableDrag) {
                            _onOverScrollDragEnd(details);
                          }
                        },
                        onInteractionStart: (details) {
                          if (_enableDrag) {
                            _onDragStart(details);
                          }
                        },
                        child: GestureDetector(
                          onDoubleTapDown: (TapDownDetails details) {
                            _doubleTapLocalPosition = details.localPosition;
                          },
                          onDoubleTap: _onDoubleTap,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (displayItems.length > 1)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.padding),
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: displayItems.length,
                      effect: ScrollingDotsEffect(
                        activeDotColor: currTheme.primary,
                        dotWidth: Constants.carouselDots,
                        dotHeight: Constants.carouselDots,
                        activeDotScale: Constants.carouselActiveDotScale,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _onDragStart(ScaleStartDetails scaleDetails) {
    _previousPosition = scaleDetails.focalPoint;
  }

  void _onDragUpdate(ScaleUpdateDetails scaleUpdateDetails) {
    final currentPosition = scaleUpdateDetails.focalPoint;
    final previousPosition = _previousPosition ?? currentPosition;

    final newY =
        (_dragOffset?.dy ?? 0.0) + (currentPosition.dy - previousPosition.dy);
    _previousPosition = currentPosition;
    if (_enableDrag) {
      setState(() {
        _dragOffset = Offset(0, newY);
      });
    }
  }

  /// Handles the end of an over-scroll drag event.
  ///
  /// If [scaleEndDetails] is not null, it checks if the drag offset exceeds a certain threshold
  /// and if the velocity is fast enough to trigger a pop action. If so, it pops the current route.
  void _onOverScrollDragEnd(ScaleEndDetails? scaleEndDetails) {
    if (_dragOffset == null) return;
    final dragOffset = _dragOffset!;

    final screenSize = MediaQuery.of(context).size;

    if (scaleEndDetails != null) {
      if (dragOffset.dy.abs() >= screenSize.height / 3) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
      final velocity = scaleEndDetails.velocity.pixelsPerSecond;
      final velocityY = velocity.dy;

      /// Make sure the velocity is fast enough to trigger the pop action
      /// Prevent mistake zoom in fast and drag => check dragOffset.dy.abs() > thresholdOffsetYToEnablePop
      const thresholdOffsetYToEnablePop = 75.0;
      const thresholdVelocityYToEnablePop = 200.0;
      if (velocityY.abs() > thresholdOffsetYToEnablePop &&
          dragOffset.dy.abs() > thresholdVelocityYToEnablePop &&
          _enableDrag) {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    }

    /// Reset position to center of the screen when the drag is canceled.
    setState(() {
      _dragAnimation = Tween<Offset>(
        begin: Offset(0.0, dragOffset.dy),
        end: const Offset(0.0, 0.0),
      ).animate(_dragAnimationController);
      _dragOffset = const Offset(0.0, 0.0);
      _dragAnimationController.forward();
    });
  }

  _onDoubleTap() {
    /// clone matrix4 current
    Matrix4 matrix = transformationController.value.clone();

    /// Get the current value to see if the image is in zoom out or zoom in state
    final double currentScale = matrix.row0.x;

    /// Suppose the current state is zoom out
    double targetScale = widget.minScale;

    /// Determines the state after a double tap action exactly
    if (currentScale <= widget.minScale) {
      targetScale = widget.maxScale / 2;
      shouldScroll = false;
    } else {
      shouldScroll = true;
    }

    /// calculate new offset of double tap
    final double offSetX = targetScale == widget.minScale
        ? 0.0
        : -_doubleTapLocalPosition.dx * (targetScale - 1);
    final double offSetY = targetScale == widget.minScale
        ? 0.0
        : -_doubleTapLocalPosition.dy * (targetScale - 1);

    matrix = Matrix4.fromList([
      targetScale,
      matrix.row1.x,
      matrix.row2.x,
      matrix.row3.x,
      matrix.row0.y,
      targetScale,
      matrix.row2.y,
      matrix.row3.y,
      matrix.row0.z,
      matrix.row1.z,
      targetScale,
      matrix.row3.z,
      offSetX,
      offSetY,
      matrix.row2.w,
      matrix.row3.w
    ]);

    _animation = Matrix4Tween(
      begin: transformationController.value,
      end: matrix,
    ).animate(
      CurveTween(curve: Curves.easeOut).animate(_animationController),
    );
    _animationController.forward(from: 0);
    setState(() {});
  }
}
