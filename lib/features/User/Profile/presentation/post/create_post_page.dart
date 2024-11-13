import 'dart:io';

import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/data/video.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/general/bullet_list.dart';
import 'package:doko_react/core/widgets/general/custom_carousel_view.dart'
    as custom;
import 'package:doko_react/core/widgets/heading/settings_heading.dart';
import 'package:doko_react/core/widgets/image_picker/image_picker_widget.dart';
import 'package:doko_react/core/widgets/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
              const SettingsHeading(
                "Just a heads up:",
                size: Constants.fontSize,
              ),
              const SizedBox(
                height: Constants.gap * 0.5,
              ),
              BulletList(postContentInfo),
              const Expanded(
                child: _PostContentWidget(),
              )
            ],
          ),
        ));
  }
}

class _PostContentWidget extends StatefulWidget {
  const _PostContentWidget();

  @override
  State<_PostContentWidget> createState() => _PostContentWidgetState();
}

class _PostContentWidgetState extends State<_PostContentWidget> {
  late final UserProvider _userProvider;

  late final String postId;
  final List<PostContent> _content = [];
  bool _compressingVideo = false;

  final custom.CarouselController carouselController =
      custom.CarouselController();

  @override
  void initState() {
    super.initState();

    postId = DisplayText.generateRandomString();
    _userProvider = context.read<UserProvider>();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  String _generateAWSPath(String path) {
    String userId = _userProvider.id;
    String randomString = DisplayText.generateRandomString();
    String extension = MediaType.getExtensionFromFileName(path) ?? "";

    return "$userId/posts/$postId/$randomString$extension";
  }

  Future<void> _handleVideo(XFile item) async {
    setState(() {
      _compressingVideo = true;
    });

    String? thumbnail = await VideoActions.getVideoThumbnail(item.path);

    PostContent tempContent;
    if (thumbnail == null) {
      tempContent = PostContent(
        type: MediaTypeValue.unknown,
        path: "",
      );
    } else {
      tempContent = PostContent(
        type: MediaTypeValue.thumbnail,
        file: File(thumbnail),
        path: "",
      );
    }

    setState(() {
      _content.add(tempContent);
    });

    String? compressedVideo = await VideoActions.compressVideo(item.path);

    setState(() {
      _compressingVideo = false;
    });

    if (compressedVideo == null) {
      // handle failed case
      String message =
          "Uh-oh, looks like we couldn't add that video. Please try selecting it again.";
      _showMessage(message);
      setState(() {
        _content.removeLast();
      });
      return;
    }

    int tempIndex = _content.length - 1;

    setState(() {
      _content[tempIndex] = PostContent(
        type: MediaTypeValue.video,
        file: File(compressedVideo),
        path: _generateAWSPath(compressedVideo),
      );
    });
  }

  void _handleMediaInfo(XFile item) {
    MediaTypeValue type = MediaType.getMediaType(item.path);
    File file = File(item.path);

    if (type == MediaTypeValue.video) {
      _handleVideo(item);
      return;
    }

    if (type == MediaTypeValue.image) {
      setState(() {
        _content.add(PostContent(
          type: type,
          file: file,
          path: _generateAWSPath(item.path),
          originalImage: file,
        ));
      });
      return;
    }

    String message =
        "It seems like we don't support that file type. Please try uploading an image or video instead.";
    _showMessage(message);
  }

  void onSelection(List<XFile> selectedFiles) {
    if (_content.length >= Constants.postLimit) return;

    // handle selected files
    for (var item in selectedFiles) {
      _handleMediaInfo(item);
    }
  }

  Widget _mediaSelect() {
    String displayText = "Select media content.";
    return ImagePickerWidget(
      displayText,
      onSelection: onSelection,
      multiple: true,
      video: true,
      multipleLimit: Constants.postLimit - _content.length,
      disabled: _compressingVideo || _content.length == Constants.postLimit,
    );
  }

  Widget _postItemWrapper({
    required Widget item,
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
          item,
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
                      CroppedFile? croppedFile = await ImageCropper().cropImage(
                        aspectRatio: const CropAspectRatio(
                          ratioX: Constants.postWidth,
                          ratioY: Constants.postHeight,
                        ),
                        sourcePath: path,
                        uiSettings: [
                          AndroidUiSettings(
                            toolbarTitle: 'Post Media Content',
                            toolbarColor: currScheme.surface,
                            toolbarWidgetColor: currScheme.onSurface,
                            statusBarColor: currScheme.surface,
                            backgroundColor: currScheme.surface,
                            dimmedLayerColor:
                                currScheme.surface.withOpacity(0.75),
                            cropFrameColor: currScheme.onSurface,
                            cropGridColor: currScheme.onSurface,
                            cropFrameStrokeWidth: 6,
                            cropGridStrokeWidth: 6,
                          ),
                          IOSUiSettings(
                            title: 'Post Media Content',
                          ),
                          WebUiSettings(
                            context: context,
                          ),
                        ],
                      );

                      if (croppedFile == null) return;

                      setState(() {
                        _content[index] = PostContent(
                          type: MediaTypeValue.image,
                          file: File(croppedFile.path),
                          path: _generateAWSPath(croppedFile.path),
                          originalImage: File(path),
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
                    var type = _content[index].type;
                    if (type == MediaTypeValue.thumbnail ||
                        type == MediaTypeValue.unknown) {
                      await VideoActions
                          .cancelCurrentlyActiveVideoCompression();
                    }

                    setState(() {
                      _content.removeAt(index);
                    });
                  },
                  icon: const Icon(
                    Icons.delete,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _handleDisplayMedia() {
    var currTheme = Theme.of(context).colorScheme;
    double opacity = 0.5;
    var width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    var height = width * (1 / Constants.postContainer);

    List<Widget> mediaWidgets = [];

    for (int i = 0; i < _content.length; i++) {
      var item = _content[i];
      var type = item.type;
      var index = i;

      switch (type) {
        case MediaTypeValue.image:
          var extension = MediaType.getExtensionFromFileName(
            item.originalImage!.path,
            withDot: false,
          );

          mediaWidgets.add(
            _postItemWrapper(
              item: Image.file(
                item.file!,
                fit: BoxFit.cover,
                cacheHeight: Constants.postCacheHeight,
                width: width,
                height: height,
              ),
              index: index,
              path: item.originalImage!.path,
              animated: extension == "gif",
            ),
          );

          break;
        case MediaTypeValue.video:
          mediaWidgets.add(
            _postItemWrapper(
              item: VideoPlayer(
                path: item.file!.path,
                key: Key(item.path),
              ),
              index: index,
              path: item.file!.path,
              animated: true,
            ),
          );
          break;
        case MediaTypeValue.thumbnail:
          mediaWidgets.add(
            _postItemWrapper(
              path: item.file!.path,
              item: Stack(
                children: [
                  Center(
                    child: Image.file(
                      item.file!,
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
        default:
          mediaWidgets.add(
            Container(
              width: width,
              color: currTheme.outlineVariant,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
          break;
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
              const SizedBox(
                height: Constants.gap,
              ),
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
                    if (_content.isNotEmpty) ..._handleDisplayMedia(),
                    if (_content.length < Constants.postLimit)
                      Container(
                        width: width,
                        color: currTheme.outlineVariant,
                        child: Center(
                          child: _mediaSelect(),
                        ),
                      ),
                  ],
                ),
              ),
              if (_content.isNotEmpty)
                _PostContentIndicator(
                  length: _content.length != 10
                      ? _content.length + 1
                      : _content.length,
                  controller: carouselController,
                ),
              const SizedBox(
                height: Constants.gap,
              ),
              Text(
                  "Selected media items: ${_content.length} / ${Constants.postLimit}."),
            ],
          ),
          FilledButton(
            onPressed: _compressingVideo
                ? null
                : () {
                    if (!mounted) return;

                    Map<String, dynamic> data = {
                      "postContent": _content,
                      "postId": postId,
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
