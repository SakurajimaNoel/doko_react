import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/archive/secret/secrets.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/media/giphy/giphy_uri.dart';
import 'package:doko_react/core/helpers/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/helpers/text-controller/mention_text_controller.dart';
import 'package:doko_react/core/helpers/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/entity/comment/comment_media.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/provider/post_provider.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  bool showMore = false;
  CommentMedia? media;

  late final PostCommentProvider commentProvider;
  final controller = MentionTextController();

  final OverlayPortalController overlayPortalController =
      OverlayPortalController(debugLabel: "user suggestions");
  final link = LayerLink();

  @override
  void initState() {
    super.initState();

    commentProvider = context.read<PostCommentProvider>();
    commentProvider.focusNode.addListener(_onFocusChange);
    controller.addListener(handleTrigger);
    safePrint("trial");
    safePrint(overlayPortalController.toString());
  }

  @override
  void dispose() {
    controller.removeListener(handleTrigger);
    controller.dispose();
    commentProvider.focusNode.removeListener(_onFocusChange);
    commentProvider.focusNode.dispose();

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

      // if (!loading) {
      //   setState(() {
      //     loading = true;
      //   });
      // }
      // usernameDebounce(() => searchUser(mentionString));

      if (!overlayPortalController.isShowing) {
        overlayPortalController.show();
      }
    } else if (overlayPortalController.isShowing) {
      overlayPortalController.hide();
    }
  }

  void _onFocusChange() {
    if (commentProvider.focusNode.hasFocus) {
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

  List<Widget> generateOverlayContent() {
    final height = MediaQuery.sizeOf(context).height / 5;
    final currTheme = Theme.of(context).colorScheme;

    bool loading = true;

    if (loading) {
      return [
        SizedBox(
          height: height,
          child: Center(
            child: const SmallLoadingIndicator(),
          ),
        ),
      ];
    }

    // if (users.isEmpty) {
    //   return [
    //     SizedBox(
    //       height: height,
    //       child: const Center(
    //         child: Text("No user found"),
    //       ),
    //     ),
    //   ];
    // }

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

    // final userList = users
    //     .map<Widget>(
    //       (user) => Container(
    //         margin: const EdgeInsets.symmetric(
    //           vertical: Constants.gap * 0.5,
    //         ),
    //         height: 55,
    //         child: Stack(
    //           fit: StackFit.expand,
    //           alignment: Alignment.center,
    //           children: [
    //             Container(
    //                 padding: const EdgeInsets.all(
    //                   Constants.gap * 0.25,
    //                 ),
    //                 child: UserWidget(user: user)),
    //             Material(
    //               color: Colors.transparent,
    //               child: InkWell(
    //                 onTap: () {
    //                   controller.addMention(user.username);
    //                 },
    //                 overlayColor: effectiveOverlayColor,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     )
    //     .toList();
    //
    // return userList;
  }

  void addMedia(CommentMedia selectedMedia) {
    setState(() {
      media = selectedMedia;
    });
  }

  void removeMedia() {
    setState(() {
      media = null;
    });
  }

  void handleAddComment(BuildContext context) {
    CommentContentInput content = controller.getCommentInput();
    String? bucketPath;

    if (media != null) {
      if (media!.extension != "uri") {
        // generate bucket path
        bucketPath =
            "${commentProvider.postCreatedBy}/posts/${commentProvider.postId}/comment/${generateUniqueString()}${media!.extension}";
      } else {
        bucketPath = media!.uri;
      }
    }

    CommentCreateInput commentDetails = CommentCreateInput(
      content: content,
      media: media,
      bucketPath: bucketPath,
      targetNodeId: commentProvider.commentTargetId,
      targetNode:
          commentProvider.isReply ? CommentTarget.comment : CommentTarget.post,
      username: (context.read<UserBloc>().state as UserCompleteState).username,
    );

    context.read<NodeCreateBloc>().add(CreateCommentEvent(
          commentDetails: commentDetails,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    final currTheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => serviceLocator<NodeCreateBloc>(),
      child: BlocConsumer<NodeCreateBloc, NodeCreateState>(
        listenWhen: (previousState, state) {
          return state is NodeCreateSuccess || state is NodeCreateError;
        },
        listener: (context, state) {
          if (state is NodeCreateError) {
            showMessage(state.message);
            return;
          }

          if (state is! NodeCreateSuccess) return;

          final UserGraph graph = UserGraph();

          String commentId = state.nodeId;
          bool userLike;
          int likesCount;
          int commentsCount;

          String targetId = commentProvider.commentTargetId;
          bool isPost = !commentProvider.isReply;

          if (isPost) {
            final PostEntity post = graph
                .getValueByKey(generatePostNodeKey(targetId))! as PostEntity;
            userLike = post.userLike;
            likesCount = post.likesCount;
            commentsCount = post.commentsCount;
          } else {
            final CommentEntity comment =
                graph.getValueByKey(generateCommentNodeKey(targetId))!
                    as CommentEntity;
            userLike = comment.userLike;
            likesCount = comment.likesCount;
            commentsCount = comment.commentsCount;
          }

          // handle success state
          removeMedia();
          commentProvider.resetCommentTarget();
          controller.clear();

          showMessage("Comment added successfully");

          // emit user action to update
          context.read<UserActionBloc>().add(
                UserActionNewCommentEvent(
                  commentId: commentId,
                  userLike: userLike,
                  commentsCount: commentsCount,
                  likesCount: likesCount,
                  targetId: targetId,
                ),
              );
        },
        builder: (context, state) {
          bool adding = state is NodeCreateLoading;

          return Column(
            children: [
              Builder(
                builder: (BuildContext context) {
                  final commentProvider = context.watch<PostCommentProvider>();

                  if (!commentProvider.isReply) {
                    return SizedBox.shrink();
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.padding,
                      vertical: Constants.padding * 0.5,
                    ),
                    color: currTheme.primaryContainer,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Replying to ${commentProvider.targetByUser}'s comment.",
                            style: TextStyle(
                              color: currTheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: adding
                              ? null
                              : () {
                                  commentProvider.resetCommentTarget();
                                },
                          style: IconButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.all(Constants.padding * 0.5),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          iconSize: Constants.width * 1.25,
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (bool didPop, var result) {
                  if (didPop) return;
                  if (adding) return;

                  if (overlayPortalController.isShowing) {
                    overlayPortalController.hide();
                  }

                  if (commentProvider.focusNode.hasFocus) {
                    commentProvider.resetCommentTarget();
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
                        if (media != null) ...[
                          _CommentMedia(
                            removeMedia: removeMedia,
                            media: media!,
                            adding: adding,
                          ),
                        ],
                        CompositedTransformTarget(
                          link: link,
                          child: OverlayPortal(
                            controller: overlayPortalController,
                            overlayChildBuilder: (BuildContext context) {
                              return CompositedTransformFollower(
                                offset: const Offset(0, -4),
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
                                        color: currTheme.surfaceContainer,
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
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
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
                              focusNode: commentProvider.focusNode,
                              minLines: 1,
                              maxLines: 3,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                hintText: "Type your comment here...",
                              ),
                              contentInsertionConfiguration:
                                  ContentInsertionConfiguration(
                                onContentInserted:
                                    (KeyboardInsertedContent data) async {
                                  if (data.hasData) {
                                    String? extension =
                                        getFileExtensionFromMimeType(
                                            data.mimeType);

                                    if (extension == null) {
                                      showMessage(Constants.errorMessage);
                                      return;
                                    }

                                    setState(() {
                                      media = CommentMedia(
                                        extension: extension,
                                        data: data.data,
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
                            height: Constants.gap * 0.25,
                          ),
                          _CommentInputActions(
                            addMedia: addMedia,
                            adding: adding,
                            addComment: handleAddComment,
                          ),
                        ],
                      ],
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
}

class _CommentInputActions extends StatefulWidget {
  const _CommentInputActions({
    required this.addMedia,
    required this.adding,
    required this.addComment,
  });

  final ValueSetter<CommentMedia> addMedia;
  final bool adding;
  final ValueSetter<BuildContext> addComment;

  @override
  State<_CommentInputActions> createState() => _CommentInputActionsState();
}

class _CommentInputActionsState extends State<_CommentInputActions> {
  late final commentProvider = context.read<PostCommentProvider>();

  Future<void> handleImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedMedia = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (selectedMedia == null) return;

    String? extension = getFileExtensionFromFileName(selectedMedia.path);

    if (extension == null) {
      showMessage("Invalid media file selected.");
      return;
    }

    if (extension == ".gif" ||
        (extension == ".webp" && await isWebpAnimated(selectedMedia.path))) {
      final animatedData = await selectedMedia.readAsBytes();
      CommentMedia media = CommentMedia(
        extension: extension,
        data: animatedData,
      );

      widget.addMedia(media);
      return;
    }

    if (!mounted) return;
    CroppedFile? croppedMedia = await getCroppedImage(
      selectedMedia.path,
      context: context,
      location: ImageLocation.comment,
    );
    if (croppedMedia == null) return;
    final mediaData = await croppedMedia.readAsBytes();
    CommentMedia media = CommentMedia(
      extension: extension,
      data: mediaData,
    );

    widget.addMedia(media);
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          onPressed: widget.adding ? null : handleImageGallery,
          style: IconButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.all(Constants.padding * 0.5),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(
            Icons.collections_outlined,
            color: currTheme.primary,
          ),
        ),
        const SizedBox(
          width: Constants.gap,
        ),
        // TODO: handle this
        IconButton(
          onPressed: widget.adding
              ? null
              : () async {
                  showMessage(Constants.errorMessage);
                  return;
                  GiphyGif? gif = await GiphyGet.getGif(
                    context: context,
                    apiKey: Secrets.giphy,
                    randomID:
                        (context.read<UserBloc>().state as UserCompleteState)
                            .username,
                    tabColor: currTheme.primary,
                    debounceTimeInMilliseconds: 500,
                  );

                  String? uri = getValidGiphyURI(gif);
                  if (uri == null || uri.isEmpty) {
                    showMessage(Constants.errorMessage);
                    return;
                  }

                  CommentMedia giphyMedia = CommentMedia(
                    extension: "uri",
                    uri: uri,
                  );
                  widget.addMedia(giphyMedia);
                },
          style: IconButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.all(Constants.padding * 0.5),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(
            Icons.gif_box_outlined,
            color: currTheme.primary,
          ),
        ),
        const Spacer(),
        Builder(builder: (context) {
          final commentProvider = context.watch<PostCommentProvider>();

          return FilledButton.icon(
            onPressed: widget.adding
                ? null
                : () {
                    widget.addComment(context);
                  },
            icon: widget.adding
                ? null
                : commentProvider.isReply
                    ? const Icon(Icons.reply)
                    : const Icon(Icons.add),
            label: widget.adding
                ? SmallLoadingIndicator()
                : commentProvider.isReply
                    ? const Text("Reply")
                    : const Text("Add"),
            style: FilledButton.styleFrom(),
          );
        }),
      ],
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }
}

class _CommentMedia extends StatelessWidget {
  const _CommentMedia({
    required this.removeMedia,
    required this.media,
    required this.adding,
  });

  final VoidCallback removeMedia;
  final CommentMedia media;
  final bool adding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    final commentMediaHeight = width / Constants.commentContainer;
    final currTheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: commentMediaHeight,
      ),
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          media.extension != "uri"
              ? Image.memory(media.data!)
              : CachedNetworkImage(
                  cacheKey: media.uri!,
                  fit: BoxFit.cover,
                  imageUrl: media.uri!,
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
            onPressed: adding
                ? null
                : () {
                    removeMedia();
                  },
            icon: Icon(
              Icons.delete,
              color: currTheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}
