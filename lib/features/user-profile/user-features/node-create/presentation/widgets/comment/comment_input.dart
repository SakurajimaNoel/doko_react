import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/text-controller/mention_text_controller.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/gif-picker/gif_picker.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/entity/comment/comment_media.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/provider/comment_input_provider.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/bloc/post_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/post/presentation/provider/post_provider.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CommentInput extends StatelessWidget {
  const CommentInput({super.key});

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height;

    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return CommentInputProvider(
          commentController: MentionTextController(),
        );
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<PostBloc>(),
          ),
          BlocProvider(
            create: (context) => serviceLocator<NodeCreateBloc>(),
          ),
        ],
        child: BlocListener<NodeCreateBloc, NodeCreateState>(
          listenWhen: (previousState, state) {
            return state is NodeCreateSuccess || state is NodeCreateError;
          },
          listener: (context, state) {
            if (state is! NodeCreateSuccess) {
              if (state is NodeCreateError) {
                showError(context, state.message);
              }
              return;
            }

            // handle success
            final UserGraph graph = UserGraph();
            final commentProvider = context.read<PostCommentProvider>();

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

            showSuccess(context, "Comment added successfully");

            // clean up
            context.read<CommentInputProvider>().reset();
            commentProvider.resetCommentTarget();

            // emit user action
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
          child: Column(
            children: [
              Builder(
                builder: (context) {
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
                        BlocBuilder<NodeCreateBloc, NodeCreateState>(
                          builder: (context, state) {
                            bool adding = state is NodeCreateLoading;

                            return IconButton(
                              onPressed: adding
                                  ? null
                                  : () {
                                      commentProvider.resetCommentTarget();
                                    },
                              style: IconButton.styleFrom(
                                minimumSize: Size.zero,
                                padding:
                                    EdgeInsets.all(Constants.padding * 0.5),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              iconSize: Constants.width * 1.25,
                              icon: const Icon(
                                Icons.close,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: Constants.padding * 0.125,
                  horizontal: Constants.padding,
                ),
                decoration: BoxDecoration(
                  color: currTheme.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(
                      width: 1.5,
                      color: currTheme.outline,
                    ),
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: height / 3.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _CommentMedia(),
                      const _CommentMentionOverlay(),
                      const SizedBox(
                        height: Constants.gap * 0.25,
                      ),
                      const _CommentInputActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// overlay
class _CommentMentionOverlay extends StatefulWidget {
  const _CommentMentionOverlay();

  @override
  State<_CommentMentionOverlay> createState() => _CommentMentionOverlayState();
}

class _CommentMentionOverlayState extends State<_CommentMentionOverlay> {
  final link = LayerLink();
  final OverlayPortalController overlayPortalController =
      OverlayPortalController();
  late final username =
      (context.read<UserBloc>().state as UserCompleteState).username;

  late final commentController =
      context.read<CommentInputProvider>().commentController;
  late final focusNode = context.read<PostCommentProvider>().focusNode;

  List<String> userSearchResults = [];

  @override
  void initState() {
    super.initState();

    focusNode.addListener(onFocusChange);
    commentController.addListener(handleTrigger);
  }

  @override
  void dispose() {
    commentController.removeListener(handleTrigger);
    commentController.dispose();
    focusNode.removeListener(onFocusChange);

    super.dispose();
  }

  void onFocusChange() {
    final inputProvider = context.read<CommentInputProvider>();

    if (focusNode.hasFocus) {
      if (!inputProvider.showMore) {
        inputProvider.updateShowMore(true);
      }
    } else {
      if (inputProvider.showMore) {
        inputProvider.updateShowMore(false);
      }
    }
  }

  void handleTrigger() {
    final String currentText = commentController.text;
    final TextSelection currentSelection = commentController.selection;

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

      UserSearchInput searchDetails = UserSearchInput(
        username: username,
        query: mentionString,
      );
      context.read<PostBloc>().add(CommentMentionSearchEvent(
            searchDetails: searchDetails,
          ));

      if (!overlayPortalController.isShowing) {
        overlayPortalController.show();
      }
    } else if (overlayPortalController.isShowing) {
      overlayPortalController.hide();
    }
  }

  Widget generateOverlayContent() {
    final height = MediaQuery.sizeOf(context).height / 5;
    final currTheme = Theme.of(context).colorScheme;

    return Material(
      color: currTheme.surfaceContainer,
      child: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previousState, state) {
          return state is CommentSearchState;
        },
        builder: (context, state) {
          bool initial = state is PostInitial;
          bool loading =
              state is CommentSearchLoading && userSearchResults.isEmpty;
          bool error = state is CommentSearchErrorState;
          bool searchResult = state is CommentSearchSuccessState;

          if (initial) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height,
                  child: const Center(
                    child: Heading(
                      "Type to search users",
                      size: Constants.fontSize,
                    ),
                  ),
                ),
              ],
            );
          }

          if (loading) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height,
                  child: const Center(
                    child: SmallLoadingIndicator(),
                  ),
                ),
              ],
            );
          }

          if (error) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height,
                  child: Center(
                    child: StyledText.error(state.message),
                  ),
                ),
              ],
            );
          }

          if (searchResult) {
            userSearchResults = state.searchResults;
          }

          if (searchResult && userSearchResults.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height,
                  child: Center(
                    child: Text(
                      "No user found with username '${state.query}'.",
                      style: TextStyle(
                        fontSize: Constants.fontSize,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: Constants.gap,
            children: [
              ...List.generate(
                userSearchResults.length,
                (index) {
                  String userKey = userSearchResults[index];
                  String username = getUsernameFromUserKey(userKey);

                  return ListTile(
                    minTileHeight: Constants.height * 3,
                    // tileColor: currTheme.surfaceContainer,
                    leading: UserWidget.avtar(
                      userKey: userKey,
                    ),
                    title: UserWidget.info(
                      userKey: userKey,
                    ),
                    onTap: () {
                      commentController.addMention(username);
                    },
                  );
                },
              ),
              if (state is CommentSearchLoading) ...[
                const SizedBox(
                  height: Constants.gap,
                ),
                SizedBox(
                  height: Constants.height,
                  child: Center(
                    child: SmallLoadingIndicator.small(),
                  ),
                ),
              ]
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    bool adding = false;

    return CompositedTransformTarget(
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
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: height / 3,
                  minHeight: Constants.commentOverlayHeight,
                  minWidth: width - Constants.padding,
                  maxWidth: width - Constants.padding,
                ),
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    vertical: Constants.padding * 0.5,
                  ),
                  scrollDirection: Axis.vertical,
                  child: generateOverlayContent(),
                ),
              ),
            ),
          );
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, var result) {
            if (didPop) return;

            if (overlayPortalController.isShowing) {
              overlayPortalController.hide();
            }

            if (adding) return;

            if (focusNode.hasFocus) {
              context.read<PostCommentProvider>().resetCommentTarget();
              FocusScope.of(context).unfocus();
              return;
            }

            context.pop();
          },
          child: BlocBuilder<NodeCreateBloc, NodeCreateState>(
            builder: (context, state) {
              adding = state is NodeCreateLoading;

              return TextField(
                enabled: !adding,
                controller: commentController,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 3,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: const InputDecoration(
                  hintText: "Type your comment here...",
                ),
                contentInsertionConfiguration: ContentInsertionConfiguration(
                  onContentInserted: (KeyboardInsertedContent data) async {
                    if (adding) return;

                    if (data.hasData) {
                      String? extension =
                          getFileExtensionFromMimeType(data.mimeType);

                      if (extension == null) {
                        showError(context, Constants.errorMessage);
                        return;
                      }

                      context.read<CommentInputProvider>().addMedia(
                            CommentMedia(
                              extension: extension,
                              data: data.data,
                            ),
                          );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CommentMedia extends StatelessWidget {
  const _CommentMedia();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - Constants.padding * 2;
    final commentMediaHeight = width / Constants.commentContainer;
    final currTheme = Theme.of(context).colorScheme;

    return Builder(builder: (context) {
      final commentInputProvider = context.watch<CommentInputProvider>();
      final media = commentInputProvider.media;

      if (media == null) {
        return SizedBox.shrink();
      }

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
                      child: SmallLoadingIndicator.small(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    filterQuality: FilterQuality.high,
                    memCacheHeight: Constants.postCacheHeight,
                  ),
            BlocBuilder<NodeCreateBloc, NodeCreateState>(
              builder: (context, state) {
                bool adding = state is NodeCreateLoading;

                return IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: currTheme.error,
                  ),
                  onPressed: adding
                      ? null
                      : () {
                          commentInputProvider.removeMedia();
                        },
                  color: currTheme.onError,
                  icon: Icon(
                    Icons.delete,
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

// input actions
class _CommentInputActions extends StatefulWidget {
  const _CommentInputActions();

  @override
  State<_CommentInputActions> createState() => _CommentInputActionsState();
}

class _CommentInputActionsState extends State<_CommentInputActions> {
  void showToastMediaError() {
    showError(context, "Invalid media file selected.");
  }

  void addMedia(CommentMedia selectedMedia) {
    context.read<CommentInputProvider>().addMedia(selectedMedia);
  }

  void handleAddComment() {
    final commentInputProvider = context.read<CommentInputProvider>();
    final commentProvider = context.read<PostCommentProvider>();

    CommentContentInput content =
        commentInputProvider.commentController.getCommentInput();
    String? bucketPath;

    final media = commentInputProvider.media;

    if (media != null) {
      if (media.extension != "uri") {
        // generate bucket path
        UserGraph graph = UserGraph();
        String key = generateUserNodeKey(commentProvider.postCreatedBy);
        final postCreatedBy = graph.getValueByKey(key)! as UserEntity;
        bucketPath =
            "${postCreatedBy.userId}/posts/${commentProvider.postId}/comment/${generateUniqueString()}${media.extension}";
      } else {
        bucketPath = media.uri;
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

  Future<void> handleCropImage({
    required String path,
    required String extension,
  }) async {
    CroppedFile? croppedMedia = await getCroppedImage(
      path,
      context: context,
      location: ImageLocation.comment,
    );
    if (croppedMedia == null) return;
    final mediaData = await croppedMedia.readAsBytes();
    CommentMedia media = CommentMedia(
      extension: extension,
      data: mediaData,
    );

    addMedia(media);
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Builder(builder: (context) {
      bool showMore =
          context.select((CommentInputProvider cip) => cip.showMore);

      return BlocBuilder<NodeCreateBloc, NodeCreateState>(
        builder: (context, state) {
          bool adding = state is NodeCreateLoading;

          if (!adding && !showMore) {
            return SizedBox.shrink();
          }

          return Row(
            children: [
              IconButton(
                onPressed: adding
                    ? null
                    : () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? selectedMedia = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (selectedMedia == null) return;

                        String? extension =
                            getFileExtensionFromFileName(selectedMedia.path);

                        if (extension == null) {
                          if (!mounted) return;
                          showToastMediaError();
                          return;
                        }

                        if (extension == ".gif" ||
                            (extension == ".webp" &&
                                await isWebpAnimated(selectedMedia.path))) {
                          final animatedData =
                              await selectedMedia.readAsBytes();
                          CommentMedia media = CommentMedia(
                            extension: extension,
                            data: animatedData,
                          );

                          addMedia(media);
                          return;
                        }

                        if (!mounted) return;

                        handleCropImage(
                          path: selectedMedia.path,
                          extension: extension,
                        );
                      },
                style: IconButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.all(Constants.padding * 0.5),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                color: currTheme.primary,
                icon: Icon(
                  Icons.collections_outlined,
                ),
              ),
              const SizedBox(
                width: Constants.gap,
              ),
              GifPicker(
                handleSelection: (String uri) {
                  CommentMedia giphyMedia = CommentMedia(
                    extension: "uri",
                    uri: uri,
                  );

                  addMedia(giphyMedia);
                },
                disabled: adding,
              ),
              const Spacer(),
              Builder(builder: (context) {
                final commentProvider = context.watch<PostCommentProvider>();

                return FilledButton.icon(
                  onPressed: adding
                      ? null
                      : () {
                          handleAddComment();
                        },
                  icon: adding
                      ? null
                      : commentProvider.isReply
                          ? const Icon(Icons.reply)
                          : const Icon(Icons.add),
                  label: adding
                      ? SmallLoadingIndicator.small()
                      : commentProvider.isReply
                          ? const Text("Reply")
                          : const Text("Add"),
                  style: FilledButton.styleFrom(),
                );
              }),
            ],
          );
        },
      );
    });
  }
}
