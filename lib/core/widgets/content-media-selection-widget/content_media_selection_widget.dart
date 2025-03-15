import 'dart:io';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/utils/media/video/video.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/bullet-list/bullet_list.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/image-picker/image_picker_widget.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/video-player/video_player.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ContentMediaSelectionWidget extends StatefulWidget {
  const ContentMediaSelectionWidget({
    super.key,
    required this.info,
    required this.nodeId,
    required this.nodeType,
    required this.onMediaChange,
    required this.onVideoProcessingChange,
  });

  final List<String> info;
  final String nodeId;
  final DokiNodeType nodeType;
  final ValueSetter<List<MediaContent>> onMediaChange;
  final ValueSetter<bool> onVideoProcessingChange;

  @override
  State<ContentMediaSelectionWidget> createState() =>
      _ContentMediaSelectionWidgetState();
}

class _ContentMediaSelectionWidgetState
    extends State<ContentMediaSelectionWidget> {
  late final String userId;
  late final String nodeId;

  late final List<String> info;

  final List<MediaContent> content = [];

  bool compressingVideo = false;
  final CarouselController carouselController = CarouselController();

  late final DokiNodeType nodeType;

  bool adding = false;

  @override
  void initState() {
    super.initState();

    nodeId = widget.nodeId;
    userId = (context.read<UserBloc>().state as UserCompleteState).id;
    info = widget.info;
    nodeType = widget.nodeType;
  }

  String generateBucketPath(String path) {
    String randomString = generateUniqueString();
    String extension = getFileExtensionFromFileName(path) ?? "";

    return "$userId/${nodeType.nodeName.toLowerCase()}/$nodeId/$randomString$extension";
  }

  Future<void> handleVideo(String item) async {
    compressingVideo = true;
    widget.onVideoProcessingChange(compressingVideo);

    String? thumbnail = await VideoActions.getVideoThumbnail(item);

    MediaContent tempContent;
    if (thumbnail == null) {
      tempContent = const MediaContent(
        type: MediaTypeValue.unknown,
        bucketPath: "",
        animated: true,
      );
    } else {
      tempContent = MediaContent(
        type: MediaTypeValue.thumbnail,
        file: thumbnail,
        bucketPath: "",
        thumbnail: thumbnail,
        animated: true,
      );
    }

    setState(() {
      content.add(tempContent);
    });

    String? compressedVideo = await VideoActions.compressVideo(item);
    compressingVideo = false;
    widget.onVideoProcessingChange(compressingVideo);

    /// only one video at a time
    int tempIndex = content.indexWhere((item) =>
        item.type == MediaTypeValue.thumbnail ||
        item.type == MediaTypeValue.unknown);
    if (tempIndex == -1) return;

    if (compressedVideo == null) {
      // handle failed case
      String message =
          "Uh-oh, looks like we couldn't add that video.\nPlease try selecting it again.";

      showError(message);
      if (mounted) {
        setState(() {
          content.removeAt(tempIndex);
        });
      }
      return;
    }

    setState(() {
      content[tempIndex] = MediaContent(
        type: MediaTypeValue.video,
        file: compressedVideo,
        bucketPath: generateBucketPath(compressedVideo),
        thumbnail: thumbnail,
        animated: true,
      );
    });

    widget.onMediaChange(content);
  }

  Future<void> handleMediaInfo(String item) async {
    MediaTypeValue type = getMediaTypeFromPath(item);

    if (type == MediaTypeValue.video) {
      handleVideo(item);
      return;
    }

    if (type == MediaTypeValue.image) {
      String extension = getFileExtensionFromFileName(item) ?? "";
      bool animated = extension == ".gif";
      if (extension == ".webp" && await isWebpAnimated(item)) {
        animated = true;
      }
      setState(() {
        content.add(MediaContent(
          type: type,
          file: item,
          bucketPath: generateBucketPath(item),
          originalImage: item,
          animated: animated,
        ));
      });
      widget.onMediaChange(content);
      return;
    }

    String message =
        "It seems like we don't support that file type.\nPlease try uploading an image or video instead.";
    showError(message);
  }

  void onSelection(List<String> selectedFiles) {
    if (!mounted) return;
    if (content.length >= Constants.mediaLimit) return;

    // handle selected files
    for (var item in selectedFiles) {
      handleMediaInfo(item);
    }
  }

  Widget mediaSelect() {
    String displayText = "Select media content.";

    return ImagePickerWidget(
      text: displayText,
      onSelection: onSelection,
      multiple: true,
      multipleLimit: Constants.mediaLimit - content.length,
      video: true,
      disabled:
          compressingVideo || content.length == Constants.mediaLimit || adding,
      adding: adding,
      selectionStatusChange: (bool adding) {
        setState(() {
          this.adding = adding;
        });
      },
    );
  }

  Widget mediaItemWrapper({
    required Widget child,
    required int index,
    bool animated = false,
    required String path,
  }) {
    var currTheme = Theme.of(context).colorScheme;

    return Stack(
      key: ObjectKey(content[index]),
      children: [
        child,
        Padding(
          padding: const EdgeInsets.only(
            right: Constants.padding * 0.5,
            top: Constants.padding * 0.5,
          ),
          child: Row(
            mainAxisAlignment: !animated
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (!animated)
                IconButton.filledTonal(
                  onPressed: () async {
                    String croppedImage = await getCroppedImage(
                      path,
                      context: context,
                      location: ImageLocation.content,
                    );

                    if (croppedImage.isEmpty) return;

                    setState(() {
                      content[index] = MediaContent(
                        type: MediaTypeValue.image,
                        file: croppedImage,
                        bucketPath: generateBucketPath(croppedImage),
                        originalImage: path,
                        animated: false,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.crop,
                  ),
                ),
              IconButton.filledTonal(
                color: currTheme.onError,
                style: IconButton.styleFrom(
                  backgroundColor: currTheme.error,
                ),
                onPressed: () async {
                  var type = content[index].type;
                  if (type == MediaTypeValue.thumbnail ||
                      type == MediaTypeValue.unknown) {
                    await VideoActions.cancelCurrentlyActiveVideoCompression();
                    compressingVideo = false;
                    widget.onVideoProcessingChange(compressingVideo);
                  }

                  setState(() {
                    content.removeAt(index);
                  });

                  widget.onMediaChange(content);
                },
                icon: const Icon(
                  Icons.delete,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> handleDisplaySelectedMedia(double width) {
    var currTheme = Theme.of(context).colorScheme;

    var height = width * (1 / Constants.contentContainer);

    List<Widget> mediaWidgets = [];

    for (int i = 0; i < content.length; i++) {
      final MediaContent item = content[i];

      final type = item.type;
      final index = i;

      switch (type) {
        case MediaTypeValue.image:
          mediaWidgets.add(
            mediaItemWrapper(
              child: Image.file(
                File(item.file!),
                fit: BoxFit.cover,
                cacheHeight: Constants.postCacheHeight,
                width: width,
                height: height,
              ),
              index: index,
              path: item.originalImage!,
              animated: item.animated,
            ),
          );

          break;
        case MediaTypeValue.video:
          mediaWidgets.add(
            mediaItemWrapper(
              child: VideoPlayer(
                path: item.file!,
                bucketPath: item.bucketPath,
                // key: Key(item.bucketPath),
              ),
              index: index,
              path: item.file!,
              animated: true,
            ),
          );
          break;
        case MediaTypeValue.thumbnail:
          mediaWidgets.add(
            mediaItemWrapper(
              path: item.file!,
              child: Stack(
                children: [
                  Center(
                    child: Image.file(
                      File(item.file!),
                      fit: BoxFit.cover,
                      cacheHeight: Constants.postCacheHeight,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: currTheme.surfaceContainer.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: const Center(
                      child: LoadingWidget.small(),
                    ),
                  ),
                ],
              ),
              index: index,
              animated: true,
            ),
          );
          break;
        case MediaTypeValue.unknown:
          mediaWidgets.add(mediaItemWrapper(
            child: Container(
              color: currTheme.outlineVariant,
              child: const Center(
                child: LoadingWidget.small(),
              ),
            ),
            index: index,
            path: "",
            animated: true,
          ));
      }
    }

    return mediaWidgets;
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, var result) {
        VideoActions.cancelCurrentlyActiveVideoCompression();

        if (!didPop) {
          context.pop();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Constants.gap * 0.5,
        children: [
          const Heading.left(
            "Just a heads up:",
            size: Constants.fontSize,
          ),
          BulletList(info),
          const SizedBox(
            height: Constants.gap * 0.25,
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = width * (1 / Constants.contentContainer);

              return Column(
                spacing: Constants.gap * 0.375,
                children: [
                  if (content.isNotEmpty)
                    SizedBox(
                      height: Constants.height * 2,
                      child: ReorderableList(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final item = content[index];
                          MediaTypeValue type = item.type;

                          final diameter = Constants.width * 2;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Constants.gap * 0.75,
                            ),
                            key: ObjectKey(item),
                            child: Row(
                              spacing: Constants.gap * 0.25,
                              children: [
                                type == MediaTypeValue.image
                                    ? ClipOval(
                                        child: Image.file(
                                          File(item.file!),
                                          fit: BoxFit.cover,
                                          cacheHeight:
                                              Constants.thumbnailCacheHeight,
                                          width: diameter,
                                          height: diameter,
                                        ),
                                      )
                                    : SizedBox(
                                        width: diameter,
                                        height: diameter,
                                        child: (item.thumbnail == null ||
                                                item.thumbnail!.isEmpty)
                                            ? Icon(
                                                Icons.video_file,
                                                color:
                                                    currTheme.primaryContainer,
                                              )
                                            : Stack(
                                                children: [
                                                  Center(
                                                    child: Image.file(
                                                      File(item.thumbnail!),
                                                      fit: BoxFit.cover,
                                                      cacheHeight: Constants
                                                          .thumbnailCacheHeight,
                                                    ),
                                                  ),
                                                  DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      color: currTheme
                                                          .surfaceContainer
                                                          .withValues(
                                                        alpha: 0.25,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: type ==
                                                              MediaTypeValue
                                                                  .thumbnail
                                                          ? const LoadingWidget
                                                              .nested()
                                                          : Icon(
                                                              Icons.play_arrow,
                                                              size:
                                                                  diameter / 2,
                                                              color: currTheme
                                                                  .primary,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(
                                    Icons.drag_handle,
                                    size: Constants.iconButtonSize * 0.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: content.length,
                        onReorder: (int prevIndex, int newIndex) {
                          setState(() {
                            if (prevIndex < newIndex) {
                              newIndex -= 1;
                            }
                            var item = content.removeAt(prevIndex);
                            content.insert(newIndex, item);
                          });
                          widget.onMediaChange(content);
                        },
                      ),
                    ),
                  SizedBox(
                    height: height,
                    child: CarouselView(
                      enableSplash: false,
                      controller: carouselController,
                      itemExtent: width,
                      shrinkExtent: width * 0.5,
                      itemSnapping: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.padding * 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Constants.radius),
                      ),
                      children: [
                        if (content.isNotEmpty)
                          ...handleDisplaySelectedMedia(width),
                        if (content.length < Constants.mediaLimit)
                          Container(
                            width: width,
                            color: currTheme.outlineVariant,
                            child: Center(
                              child: mediaSelect(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          if (content.isNotEmpty)
            _MediaContentIndicator(
              length: content.length == Constants.mediaLimit
                  ? Constants.mediaLimit
                  : content.length + 1, // handle media selection widget
              controller: carouselController,
            )
        ],
      ),
    );
  }
}

class _MediaContentIndicator extends StatefulWidget {
  final int length;
  final ScrollController controller;

  const _MediaContentIndicator({
    required this.length,
    required this.controller,
  });

  @override
  State<_MediaContentIndicator> createState() => _MediaContentIndicatorState();
}

class _MediaContentIndicatorState extends State<_MediaContentIndicator> {
  int activeItem = 0;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      int active = getActiveItem();
      if (active != activeItem) {
        setState(() {
          activeItem = active;
        });
      }
    });
  }

  int getActiveItem() {
    double offset =
        widget.controller.hasClients ? widget.controller.offset : -1;
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;

    int item = (offset / width).round();

    return item;
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(
          height: Constants.gap * 0.5,
        ),
        Center(
          child: AnimatedSmoothIndicator(
            activeIndex: activeItem,
            count: widget.length,
            effect: ScrollingDotsEffect(
              activeDotColor: currTheme.primary,
              dotWidth: Constants.carouselDots,
              dotHeight: Constants.carouselDots,
              activeDotScale: Constants.carouselActiveDotScale,
            ),
          ),
        ),
      ],
    );
  }
}
