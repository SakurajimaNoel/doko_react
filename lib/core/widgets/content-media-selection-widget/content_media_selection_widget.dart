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
import 'package:doko_react/core/widgets/video-player/video_player.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
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
      );
    } else {
      tempContent = MediaContent(
        type: MediaTypeValue.thumbnail,
        file: thumbnail,
        bucketPath: "",
      );
    }

    setState(() {
      content.add(tempContent);
    });

    String? compressedVideo = await VideoActions.compressVideo(item);
    compressingVideo = false;
    widget.onVideoProcessingChange(compressingVideo);

    if (compressedVideo == null) {
      // handle failed case
      String message =
          "Uh-oh, looks like we couldn't add that video.\nPlease try selecting it again.";

      showError(message);
      if (mounted) {
        setState(() {
          content.removeLast();
        });
      }
      return;
    }

    int tempIndex = content.length - 1;
    setState(() {
      content[tempIndex] = MediaContent(
        type: MediaTypeValue.video,
        file: compressedVideo,
        bucketPath: generateBucketPath(compressedVideo),
      );
    });

    widget.onMediaChange(content);
  }

  void handleMediaInfo(String item) {
    MediaTypeValue type = getMediaTypeFromPath(item);

    if (type == MediaTypeValue.video) {
      handleVideo(item);
      return;
    }

    if (type == MediaTypeValue.image) {
      setState(() {
        content.add(MediaContent(
          type: type,
          file: item,
          bucketPath: generateBucketPath(item),
          originalImage: item,
        ));
      });
      widget.onMediaChange(content);
      return;
    }

    String message =
        "It seems like we don't support that file type.\nPlease try uploading an image or video instead.";
    showError(message);
  }

  void onSelection(List<XFile> selectedFiles) {
    if (content.length >= Constants.mediaLimit) return;

    // handle selected files
    for (var item in selectedFiles) {
      handleMediaInfo(item.path);
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
      disabled: compressingVideo || content.length == Constants.mediaLimit,
    );
  }

  Widget discussionItemWrapper({
    required Widget child,
    required int index,
    bool animated = false,
    required String path,
  }) {
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    var currTheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Stack(
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
                      CroppedFile? croppedImage = await getCroppedImage(
                        path,
                        context: context,
                        location: ImageLocation.post,
                      );

                      if (croppedImage == null) return;

                      setState(() {
                        content[index] = MediaContent(
                          type: MediaTypeValue.image,
                          file: croppedImage.path,
                          bucketPath: generateBucketPath(croppedImage.path),
                          originalImage: path,
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
                      await VideoActions
                          .cancelCurrentlyActiveVideoCompression();
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
      ),
    );
  }

  List<Widget> handleDisplaySelectedMedia() {
    var currTheme = Theme.of(context).colorScheme;
    double opacity = 0.5;
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    var height = width * (1 / Constants.postContainer);

    List<Widget> mediaWidgets = [];

    for (int i = 0; i < content.length; i++) {
      final MediaContent item = content[i];

      final type = item.type;
      final index = i;

      switch (type) {
        case MediaTypeValue.image:
          String? extension = getFileExtensionFromFileName(item.originalImage!);

          mediaWidgets.add(
            discussionItemWrapper(
              child: Image.file(
                File(item.file!),
                fit: BoxFit.cover,
                cacheHeight: Constants.postCacheHeight,
                width: width,
                height: height,
              ),
              index: index,
              path: item.originalImage!,
              animated: extension == ".gif",
            ),
          );

          break;
        case MediaTypeValue.video:
          mediaWidgets.add(
            discussionItemWrapper(
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
            discussionItemWrapper(
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          currTheme.surface.withValues(alpha: opacity),
                          currTheme.surface.withValues(alpha: opacity),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              ),
              index: index,
              animated: true,
            ),
          );
          break;
        case MediaTypeValue.unknown:
          mediaWidgets.add(discussionItemWrapper(
            child: Container(
              width: width,
              color: currTheme.outlineVariant,
              child: const Center(
                child: CircularProgressIndicator(),
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
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    var height = width * (1 / Constants.postContainer);

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
            height: Constants.gap * 0.5,
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
                if (content.isNotEmpty) ...handleDisplaySelectedMedia(),
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
          if (content.isNotEmpty) ...[
            const SizedBox(
              height: Constants.gap * 0.5,
            ),
            _MediaContentIndicator(
              length: content.length == Constants.mediaLimit
                  ? Constants.mediaLimit
                  : content.length + 1,
              controller: carouselController,
            )
          ],
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
