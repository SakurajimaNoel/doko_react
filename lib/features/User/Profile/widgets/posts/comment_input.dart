import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/data/storage.dart';
import 'package:doko_react/core/data/text_mention_controller.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/debounce.dart';
import 'package:doko_react/core/helpers/display.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/features/User/Profile/widgets/user/user_widget.dart';
import 'package:doko_react/features/User/data/model/comment_model.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:doko_react/secret/secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CommentMediaData {
  final Uint8List media;
  final String extension;

  const CommentMediaData({
    required this.media,
    required this.extension,
  });
}

class CommentInput extends StatefulWidget {
  final String postId;
  final String createdBy;
  final String commentTargetId;
  final ValueSetter<CommentModel> successAction;

  const CommentInput({
    super.key,
    required this.postId,
    required this.commentTargetId,
    required this.successAction,
    required this.createdBy,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  FocusNode focusNode = FocusNode();
  bool showMore = false;
  bool adding = false;
  late bool isReply;

  final StorageActions storage = StorageActions(storage: Amplify.Storage);
  CommentMediaData? mediaData;
  String? mediaUrl;

  final controller = TextMentionController();

  final OverlayPortalController overlayPortalController =
      OverlayPortalController(debugLabel: "user suggestions");
  final link = LayerLink();

  late final UserProvider userProvider;
  final UserGraphqlService userGraphqlService = UserGraphqlService(
    client: GraphqlConfig.getGraphQLClient(),
  );
  final Debounce usernameDebounce = Debounce(const Duration(
    milliseconds: 250,
  ));
  bool loading = false;
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChange);
    userProvider = context.read<UserProvider>();
    controller.addListener(handleTrigger);

    isReply = widget.postId != widget.commentTargetId;
  }

  @override
  void dispose() {
    controller.removeListener(handleTrigger);
    controller.dispose();
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  void handleTrigger() {
    final String currentText = controller.text;
    final TextSelection currentSelection = controller.selection;

    final int offset = currentSelection.start;

    if (offset < 0) {
      if (overlayPortalController.isShowing) overlayPortalController.hide();
      return;
    }
    final String beforeSelection = currentText.substring(0, offset);

    if (beforeSelection.isEmpty) {
      if (overlayPortalController.isShowing) overlayPortalController.hide();
      return;
    }

    // trigger only after @
    if (beforeSelection.characters.last == " ") {
      if (overlayPortalController.isShowing) overlayPortalController.hide();
      return;
    }

    String beforeSelectionLast = beforeSelection.split(" ").last;

    if (beforeSelectionLast.contains("@")) {
      // use this string to fetch user based on the conditions
      String mentionString = beforeSelectionLast
          .substring(beforeSelectionLast.lastIndexOf("@") + 1);

      if (mentionString.contains(Constants.zeroWidthSpace)) return;

      if (!loading) {
        setState(() {
          loading = true;
        });
      }
      usernameDebounce(() => searchUser(mentionString));

      if (!overlayPortalController.isShowing) {
        overlayPortalController.show();
      }
    } else if (overlayPortalController.isShowing) {
      overlayPortalController.hide();
    }
  }

  Future<void> searchUser(String usernameQuery) async {
    if (!loading) {
      setState(() {
        loading = true;
      });
    }

    var searchResponse = await userGraphqlService.searchUserFriendsByUsername(
      userProvider.username,
      query: usernameQuery,
    );

    setState(() {
      loading = false;
    });

    if (searchResponse.status == ResponseStatus.error) {
      String message = Constants.errorMessage;
      showMessage(message);
      return;
    }

    setState(() {
      users = searchResponse.users;
    });
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

  Future<void> handleImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    String? extension =
        MediaType.getExtensionFromFileName(image.path, withDot: false);

    if (extension == null) {
      showMessage("Invalid image file selected.");
      return;
    }

    if (extension == "gif" ||
        (extension == "webp" && await MediaType.isAnimated(image.path))) {
      final animatedData = await image.readAsBytes();
      setState(() {
        mediaData = CommentMediaData(
          media: animatedData,
          extension: ".$extension",
        );
      });
      return;
    }

    if (!mounted) return;
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
      mediaData = CommentMediaData(
        media: finalMedia,
        extension: extension,
      );
    });
  }

  void handleGifSelection(String? url) {
    setState(() {
      mediaUrl = url;
      mediaData = null;
    });
  }

  void handleMediaRemove() {
    setState(() {
      mediaUrl = null;
      mediaData = null;
    });
  }

  List<Widget> generateOverlayContent() {
    final height = MediaQuery.sizeOf(context).height / 5;
    final currTheme = Theme.of(context).colorScheme;

    if (loading) {
      return [
        SizedBox(
          height: height,
          child: Center(
            child: Transform.scale(
              scale: 0.75,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      ];
    }

    if (users.isEmpty) {
      return [
        SizedBox(
          height: height,
          child: const Center(
            child: Text("No user found"),
          ),
        ),
      ];
    }

    // for ink splash
    final WidgetStateProperty<Color?> effectiveOverlayColor =
        WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return currTheme.onSurface.withOpacity(0.1);
      }
      if (states.contains(WidgetState.hovered)) {
        return currTheme.onSurface.withOpacity(0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return currTheme.onSurface.withOpacity(0.1);
      }
      return null;
    });

    final userList = users
        .map<Widget>(
          (user) => Container(
            margin: const EdgeInsets.symmetric(
              vertical: Constants.gap * 0.5,
            ),
            height: 55,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Container(
                    padding: const EdgeInsets.all(
                      Constants.gap * 0.25,
                    ),
                    child: UserWidget(user: user)),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      controller.addMention(user.username);
                    },
                    overlayColor: effectiveOverlayColor,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();

    return userList;
  }

  Future<void> handleComment() async {
    setState(() {
      adding = true;
    });

    String media = "";
    bool aws = false;

    if (mediaData != null) {
      // upload to aws media
      aws = true;
      String imageString = DisplayText.generateRandomString();
      String bucketPath =
          "${widget.createdBy}/posts/${widget.postId}/comment/$imageString${mediaData!.extension}";
      media = bucketPath;

      var mediaResult = await storage.uploadBytes(mediaData!.media, bucketPath);
      if (mediaResult.status == ResponseStatus.error) {
        showMessage(Constants.errorMessage);
        return;
      }
    } else if (mediaUrl != null) {
      media = mediaUrl!;
    }

    var currentInput = controller.getCommentInput();
    CommentInputModel commentInput = CommentInputModel(
      media: media,
      mentions: currentInput.mentions.toList(),
      content: currentInput.content,
      commentBy: userProvider.username,
      commentOn: widget.commentTargetId,
      isReply: isReply,
    );

    var result = await userGraphqlService.addComment(commentInput);
    setState(() {
      adding = false;
    });

    if (result == null) {
      if (aws) {
        storage.deleteFile(media);
      }
      showMessage(Constants.errorMessage);
      return;
    }

    // todo handle adding comment to display
    showMessage("Comment posted successfully");
    // cleanup
    controller.clear();
    handleMediaRemove();
    widget.successAction(result);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    final currTheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, var result) {
        if (didPop) return;

        if (focusNode.hasFocus) {
          FocusScope.of(context).unfocus();
          return;
        }
        context.pop();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: currTheme.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              width: 1.5,
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
                _CommentInputMedia(
                  mediaData: mediaData,
                  mediaUrl: mediaUrl,
                  handleMediaRemove: handleMediaRemove,
                ),
              CompositedTransformTarget(
                link: link,
                child: OverlayPortal(
                  controller: overlayPortalController,
                  overlayChildBuilder: (BuildContext context) {
                    return CompositedTransformFollower(
                      offset: const Offset(0, -6),
                      link: link,
                      targetAnchor: Alignment.topCenter,
                      followerAnchor: Alignment.bottomCenter,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: height / 2.5,
                            minHeight: Constants.commentOverlayHeight,
                            minWidth: width - Constants.padding,
                            maxWidth: width - Constants.padding,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: currTheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 16,
                                  color: currTheme.shadow,
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(
                                  Constants.padding * 0.75),
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: generateOverlayContent(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: TextField(
                    autofocus: true,
                    enabled: !adding,
                    controller: controller,
                    focusNode: focusNode,
                    minLines: 1,
                    maxLines: 3,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: const InputDecoration(
                      hintText: "Type your comment here...",
                    ),
                    contentInsertionConfiguration:
                        ContentInsertionConfiguration(
                      onContentInserted: (KeyboardInsertedContent data) async {
                        if (data.hasData) {
                          String? extension =
                              MediaType.getExtension(data.mimeType);
                          if (extension == null) {
                            showMessage(Constants.errorMessage);
                            return;
                          }
                          setState(() {
                            mediaData = CommentMediaData(
                              media: data.data!,
                              extension: extension,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (showMore || adding) ...[
                const SizedBox(
                  height: 4,
                ),
                _CommentInputActions(
                  handleImageGallery: handleImageGallery,
                  handleGifSelection: handleGifSelection,
                  isReply: isReply,
                  handleComment: handleComment,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentInputActions extends StatefulWidget {
  final AsyncCallback handleImageGallery;
  final ValueSetter<String?> handleGifSelection;
  final bool isReply;
  final AsyncCallback handleComment;

  const _CommentInputActions({
    required this.handleImageGallery,
    required this.handleGifSelection,
    required this.isReply,
    required this.handleComment,
  });

  @override
  State<_CommentInputActions> createState() => _CommentInputActionsState();
}

class _CommentInputActionsState extends State<_CommentInputActions> {
  late final UserProvider userProvider;
  bool adding = false;

  Future<void> handleCommentAdd() async {
    setState(() {
      adding = true;
    });
    await widget.handleComment();
    setState(() {
      adding = false;
    });
  }

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            widget.handleImageGallery();
          },
          child: Icon(
            Icons.collections_outlined,
            color: currTheme.primary,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        // TODO: handle this
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

            widget.handleGifSelection(gif.images?.downsized?.url);
          },
          child: Icon(
            Icons.gif_box_outlined,
            color: currTheme.primary,
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: adding ? null : handleCommentAdd,
          icon: adding
              ? null
              : widget.isReply
                  ? const Icon(Icons.reply)
                  : const Icon(Icons.add),
          label: adding
              ? Transform.scale(
                  scale: 0.5,
                  child: const CircularProgressIndicator(),
                )
              : widget.isReply
                  ? const Text("Reply")
                  : const Text("Add"),
          style: FilledButton.styleFrom(),
        ),
      ],
    );
  }
}

class _CommentInputMedia extends StatelessWidget {
  final CommentMediaData? mediaData;
  final String? mediaUrl;
  final VoidCallback handleMediaRemove;

  const _CommentInputMedia({
    required this.mediaData,
    required this.mediaUrl,
    required this.handleMediaRemove,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final commentMediaHeight = width / Constants.commentContainer;
    final currTheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: commentMediaHeight,
      ),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          mediaData != null
              ? Image.memory(mediaData!.media)
              : CachedNetworkImage(
                  cacheKey: mediaUrl!,
                  fit: BoxFit.cover,
                  imageUrl: mediaUrl!,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  filterQuality: FilterQuality.high,
                  memCacheHeight: Constants.postCacheHeight,
                ),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: currTheme.error,
            ),
            onPressed: () {
              handleMediaRemove();
            },
            icon: Icon(
              Icons.delete,
              color: currTheme.onError,
            ),
          )
        ],
      ),
    );
  }
}
