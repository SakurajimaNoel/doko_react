import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/data/text_mention_controller.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/secret/secrets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  FocusNode focusNode = FocusNode();
  bool showMore = false;
  Uint8List? mediaData;
  String? mediaUrl;
  final controller = TextMentionController();
  late final UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
    userProvider = context.read<UserProvider>();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();

    super.dispose();
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        showMore = true;
      });
    } else {
      if (mounted) {
        setState(() {
          showMore = false;
        });
      }
    }
  }

  Future<void> _selectImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    String? extension =
        MediaType.getExtensionFromFileName(image.path, withDot: false);

    if (extension == "gif" ||
        (extension == "webp" && await MediaType.isAnimated(image.path))) {
      final animatedData = await image.readAsBytes();
      setState(() {
        mediaData = animatedData;
      });
      return;
    }

    var currScheme = Theme.of(context).colorScheme;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(
        ratioX: Constants.commentWidth,
        ratioY: Constants.commentHeight,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Comment Media',
          toolbarColor: currScheme.surface,
          toolbarWidgetColor: currScheme.onSurface,
          statusBarColor: currScheme.surface,
          backgroundColor: currScheme.surface,
          dimmedLayerColor: currScheme.surface.withOpacity(0.75),
          cropFrameColor: currScheme.onSurface,
          cropGridColor: currScheme.onSurface,
          cropFrameStrokeWidth: 6,
          cropGridStrokeWidth: 6,
        ),
        IOSUiSettings(
          title: 'Comment Media',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile == null) return;
    final finalMedia = await croppedFile.readAsBytes();
    setState(() {
      mediaData = finalMedia;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final commentMediaHeight = width / Constants.commentContainer;
    final currTheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: currTheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            width: 1,
            color: currTheme.outline,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Constants.padding * 0.125,
          horizontal: Constants.padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mediaData != null || mediaUrl != null)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: commentMediaHeight,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    mediaData != null
                        ? Image.memory(mediaData!)
                        : CachedNetworkImage(
                            cacheKey: mediaUrl!,
                            fit: BoxFit.cover,
                            imageUrl: mediaUrl!,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            filterQuality: FilterQuality.high,
                            memCacheHeight: Constants.postCacheHeight,
                          ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: currTheme.error,
                      ),
                      onPressed: () {
                        setState(() {
                          mediaData = null;
                          mediaUrl = null;
                        });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: currTheme.onError,
                      ),
                    )
                  ],
                ),
              ),
            TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 3,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(
                hintText: "Type your comment here...",
              ),
              contentInsertionConfiguration: ContentInsertionConfiguration(
                onContentInserted: (KeyboardInsertedContent data) async {
                  if (data.hasData) {
                    setState(() {
                      mediaData = data.data;
                    });
                  }
                },
              ),
            ),
            if (showMore) ...[
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectImageGallery();
                    },
                    child: Icon(
                      Icons.collections_outlined,
                      color: currTheme.primary,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  GestureDetector(
                    onTap: () async {
                      GiphyGif? gif = await GiphyGet.getGif(
                        context: context,
                        apiKey: Secrets.giphy,
                        randomID: userProvider.id,
                        tabColor: currTheme.primary,
                        debounceTimeInMilliseconds: 500,
                      );
                      if (gif == null) return;
                      setState(() {
                        mediaUrl = gif.images?.downsized?.url;
                        mediaData = null;
                      });
                    },
                    child: Icon(
                      Icons.gif_box_outlined,
                      color: currTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("Add"),
                    style: FilledButton.styleFrom(),
                  ),
                ],
              )
            ],
          ],
        ),
      ),
    );
  }
}
