import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/core/data/text_mention_controller.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/helpers/debounce.dart';
import 'package:doko_react/core/helpers/enum.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/features/User/Profile/widgets/user/user_widget.dart';
import 'package:doko_react/features/User/data/model/user_model.dart';
import 'package:doko_react/features/User/data/services/user_graphql_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        duration: const Duration(
          milliseconds: 750,
        ),
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

      if (mentionString.endsWith(Constants.zeroWidthSpace)) return;

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

    if (extension == "gif" ||
        (extension == "webp" && await MediaType.isAnimated(image.path))) {
      final animatedData = await image.readAsBytes();
      setState(() {
        mediaData = animatedData;
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
      mediaData = finalMedia;
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

    // for inksplash
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
                      // showMessage(user.username);
                    },
                    overlayColor: effectiveOverlayColor,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();

    return userList + userList + userList;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    final currTheme = Theme.of(context).colorScheme;

    return DecoratedBox(
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
                            padding:
                                const EdgeInsets.all(Constants.padding * 0.75),
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
              ),
            ),
            if (showMore) ...[
              const SizedBox(
                height: 4,
              ),
              _CommentInputActions(
                handleImageGallery: handleImageGallery,
                handleGifSelection: handleGifSelection,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommentInputActions extends StatelessWidget {
  final AsyncCallback handleImageGallery;
  final ValueSetter<String?> handleGifSelection;

  const _CommentInputActions({
    required this.handleImageGallery,
    required this.handleGifSelection,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = context.read<UserProvider>();
    final currTheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            handleImageGallery();
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
        // GestureDetector(
        //   onTap: () async {
        //     GiphyGif? gif = await GiphyGet.getGif(
        //       context: context,
        //       apiKey: Secrets.giphy,
        //       randomID: userProvider.id,
        //       tabColor: currTheme.primary,
        //       debounceTimeInMilliseconds: 500,
        //     );
        //     if (gif == null) return;
        //
        //     handleGifSelection(gif.images?.downsized?.url);
        //   },
        //   child: Icon(
        //     Icons.gif_box_outlined,
        //     color: currTheme.primary,
        //   ),
        // ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text("Add"),
          style: FilledButton.styleFrom(),
        ),
      ],
    );
  }
}

class _CommentInputMedia extends StatelessWidget {
  final Uint8List? mediaData;
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
              ? Image.memory(mediaData!)
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
