import 'dart:io';

import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/helpers/media/video/video.dart';
import 'package:doko_react/core/helpers/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/bullet-list/bullet_list.dart';
import 'package:doko_react/core/widgets/carousel/custom_carousel_view.dart'
    as custom;
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

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> postContentInfo = [
      "You can add up to ${Constants.postLimit} media items per post.",
      "Keep your videos under ${Constants.videoDuration.inSeconds} seconds. Longer videos will be automatically trimmed.",
      "GIFs are typically designed to loop seamlessly, so cropping them might disrupt their intended animation.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Constants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading.left(
              "Just a heads up:",
              size: Constants.fontSize,
            ),
            const SizedBox(
              height: Constants.gap * 0.5,
            ),
            BulletList(postContentInfo),
            const SizedBox(
              height: Constants.gap,
            ),
            const Expanded(
              child: _PostContentWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostContentWidget extends StatefulWidget {
  const _PostContentWidget();

  @override
  State<_PostContentWidget> createState() => _PostContentWidgetState();
}

class _PostContentWidgetState extends State<_PostContentWidget> {
  late final String postId;
  late final String userId;

  final List<PostContent> content = [];

  bool compressingVideo = false;
  final custom.CarouselController carouselController =
      custom.CarouselController();

  @override
  void initState() {
    super.initState();

    postId = generateUniqueString();
    userId = (context.read<UserBloc>().state as UserCompleteState).id;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  String generateBucketPath(String path) {
    String randomString = generateUniqueString();
    String extension = getFileExtensionFromFileName(path) ?? "";

    return "$userId/posts/$postId/$randomString$extension";
  }

  Future<void> handleVideo(String item) async {
    compressingVideo = true;

    String? thumbnail = await VideoActions.getVideoThumbnail(item);

    PostContent tempContent;
    if (thumbnail == null) {
      tempContent = const PostContent(
        type: MediaTypeValue.unknown,
        bucketPath: "",
      );
    } else {
      tempContent = PostContent(
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

    if (compressedVideo == null) {
      // handle failed case
      String message =
          "Uh-oh, looks like we couldn't add that video. Please try selecting it again.";
      showMessage(message);
      setState(() {
        content.removeLast();
      });
      return;
    }

    int tempIndex = content.length - 1;
    setState(() {
      content[tempIndex] = PostContent(
        type: MediaTypeValue.video,
        file: compressedVideo,
        bucketPath: generateBucketPath(compressedVideo),
      );
    });
  }

  void handleMediaInfo(String item) {
    MediaTypeValue type = getMediaTypeFromPath(item);

    if (type == MediaTypeValue.video) {
      handleVideo(item);
      return;
    }

    if (type == MediaTypeValue.image) {
      setState(() {
        content.add(PostContent(
          type: type,
          file: item,
          bucketPath: generateBucketPath(item),
          originalImage: item,
        ));
      });
      return;
    }

    String message =
        "It seems like we don't support that file type. Please try uploading an image or video instead.";
    showMessage(message);
  }

  void onSelection(List<XFile> selectedFiles) {
    if (content.length >= Constants.postLimit) return;

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
      multipleLimit: Constants.postLimit - content.length,
      video: true,
      disabled: compressingVideo || content.length == Constants.postLimit,
    );
  }

  Widget postItemWrapper({
    required Widget child,
    required int index,
    bool animated = false,
    required String path,
  }) {
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    var currScheme = Theme.of(context).colorScheme;

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
                        content[index] = PostContent(
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
                  color: currScheme.onError,
                  style: IconButton.styleFrom(
                    backgroundColor: currScheme.error,
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
      final PostContent item = content[i];

      final type = item.type;
      final index = i;

      switch (type) {
        case MediaTypeValue.image:
          String? extension = getFileExtensionFromFileName(item.originalImage!);

          mediaWidgets.add(
            postItemWrapper(
              child: Image.file(
                File(item.file!),
                fit: BoxFit.cover,
                cacheHeight: Constants.postCacheHeight,
                width: width,
                height: height,
              ),
              index: index,
              path: item.originalImage!,
              animated: extension == "gif",
            ),
          );

          break;
        case MediaTypeValue.video:
          mediaWidgets.add(
            postItemWrapper(
              child: VideoPlayer(
                path: item.file!,
                key: Key(item.bucketPath),
              ),
              index: index,
              path: item.file!,
              animated: true,
            ),
          );
          break;
        case MediaTypeValue.thumbnail:
          mediaWidgets.add(
            postItemWrapper(
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
                          currTheme.surface.withOpacity(opacity),
                          currTheme.surface.withOpacity(opacity),
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
          mediaWidgets.add(postItemWrapper(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: height,
                child: custom.CustomCarouselView(
                  controller: carouselController,
                  itemExtent: width,
                  shrinkExtent: width * 0.5,
                  itemSnapping: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.padding * 0.5,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(Constants.radius * 0.5),
                    ),
                  ),
                  children: [
                    if (content.isNotEmpty) ...handleDisplaySelectedMedia(),
                    if (content.length < Constants.postLimit)
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
                _PostContentIndicator(
                  length: content.length == 10 ? 10 : content.length + 1,
                  controller: carouselController,
                )
              ]
            ],
          ),
          FilledButton(
            onPressed: () {
              Map<String, dynamic> data = {
                "postDetails": PostPublishPageData(
                  content: content,
                  postId: postId,
                ),
              };

              context.pushNamed(
                RouterConstants.postPublish,
                extra: data,
              );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(
                Constants.buttonWidth,
                Constants.buttonHeight,
              ),
            ),
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }
}

class _PostContentIndicator extends StatefulWidget {
  final int length;
  final ScrollController controller;

  const _PostContentIndicator({
    required this.length,
    required this.controller,
  });

  @override
  State<_PostContentIndicator> createState() => _PostContentIndicatorState();
}

class _PostContentIndicatorState extends State<_PostContentIndicator> {
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
