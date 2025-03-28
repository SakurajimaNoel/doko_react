import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/text-controller/mention_text_controller.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/gif-picker/gif_picker.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/entity/comment/comment_media.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/comment_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/provider/comment_input_provider.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/bloc/profile_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/root-node/presentation/provider/node_comment_provider.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CommentInput extends StatelessWidget {
  const CommentInput({super.key});

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final height = MediaQuery.sizeOf(context).height;

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return CommentInputProvider(
          commentController: MentionTextController(),
        );
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<NodeCreateBloc>(),
          ),
          // when user types only @ than shows user friends
          BlocProvider(
            create: (context) => serviceLocator<ProfileBloc>()
              ..add(GetUserFriendsEvent(
                userDetails: UserProfileNodesInput(
                  username: username,
                  currentUsername: username,
                ),
              )),
          ),
        ],
        child: BlocListener<NodeCreateBloc, NodeCreateState>(
          listenWhen: (previousState, state) {
            return state is NodeCreateSuccess || state is NodeCreateError;
          },
          listener: (context, state) {
            if (state is! NodeCreateSuccess) {
              if (state is NodeCreateError) {
                showError(state.message);
              }
              return;
            }

            // handle success
            final UserGraph graph = UserGraph();
            final commentProvider = context.read<NodeCommentProvider>();

            String commentId = state.nodeId;
            bool userLike = false;
            int likesCount = 0;
            int commentsCount = 0;

            String targetId = commentProvider.commentTargetId;

            if (commentProvider.commentTargetNodeType == DokiNodeType.post) {
              final PostEntity post = graph
                  .getValueByKey(generatePostNodeKey(targetId))! as PostEntity;
              userLike = post.userLike;
              likesCount = post.likesCount;
              commentsCount = post.commentsCount;
            }
            if (commentProvider.commentTargetNodeType == DokiNodeType.comment) {
              final CommentEntity comment =
                  graph.getValueByKey(generateCommentNodeKey(targetId))!
                      as CommentEntity;
              userLike = comment.userLike;
              likesCount = comment.likesCount;
              commentsCount = comment.commentsCount;
            }

            showSuccess("Comment added successfully");

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
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) {
                  final commentProvider = context.watch<NodeCommentProvider>();

                  if (!commentProvider.isReply) {
                    return const SizedBox.shrink();
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
                                padding: const EdgeInsets.all(
                                    Constants.padding * 0.5),
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
                  maxHeight: height / 2.5,
                ),
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CommentMedia(),
                      _CommentMentionOverlay(),
                      SizedBox(
                        height: Constants.gap * 0.25,
                      ),
                      _CommentInputActions(),
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
  late final focusNode = context.read<NodeCommentProvider>().focusNode;

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
      context.read<ProfileBloc>().add(CommentMentionSearchEvent(
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
      child: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (previousState, state) {
          return state is CommentSearchState ||
              state is ProfileInitial ||
              state is ProfileLoading;
        },
        builder: (context, state) {
          bool initial = state is ProfileInitial;
          bool loading =
              (state is CommentSearchLoading || state is ProfileLoading) &&
                  userSearchResults.isEmpty;
          bool error = state is CommentSearchErrorState;
          bool searchResult = state is CommentSearchSuccessState;

          if (initial) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height,
                  child: const Center(
                    child: Text(
                      "Type to search users",
                      style: TextStyle(
                        fontSize: Constants.fontSize,
                        fontWeight: FontWeight.w500,
                      ),
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
                    child: LoadingWidget.small(),
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
                      style: const TextStyle(
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
                const SizedBox(
                  height: Constants.height,
                  child: Center(
                    child: LoadingWidget.small(),
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
                  borderRadius: BorderRadius.circular(Constants.radius),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      color: currTheme.shadow.withValues(
                        alpha: 0.5,
                      ),
                      spreadRadius: 0,
                      blurRadius: 10,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
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
              context.read<NodeCommentProvider>().resetCommentTarget();
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
                        showError(Constants.errorMessage);
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
        return const SizedBox.shrink();
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
                      child: LoadingWidget.small(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
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
                  icon: const Icon(
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
  void addMedia(CommentMedia selectedMedia) {
    context.read<CommentInputProvider>().addMedia(selectedMedia);
  }

  void handleAddComment() {
    final commentInputProvider = context.read<CommentInputProvider>();
    final commentProvider = context.read<NodeCommentProvider>();

    CommentContentInput content =
        commentInputProvider.commentController.getCommentInput();
    String? bucketPath;

    final media = commentInputProvider.media;

    if (media != null) {
      if (media.extension != "uri") {
        // generate bucket path
        bucketPath =
            "${commentProvider.rootNodeCreatedBy}/${commentProvider.rootNodeType.nodeName.toLowerCase()}/${commentProvider.rootNodeId}/comment/${generateUniqueString()}${media.extension}";
      } else {
        bucketPath = media.uri;
      }
    }

    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    CommentCreateInput commentDetails = CommentCreateInput(
      content: content,
      media: media,
      bucketPath: bucketPath,
      targetNodeId: commentProvider.commentTargetId,
      targetNode: commentProvider.commentTargetNodeType,
      username: username,
      replyOn: commentProvider.replyOn,
    );

    String? replyOnNodeCreatedBy;
    if (commentProvider.replyOn != null) {
      UserGraph graph = UserGraph();

      final commentKey = generateCommentNodeKey(commentProvider.replyOn!);
      final comment = graph.getValueByKey(commentKey);

      if (comment is CommentEntity) {
        replyOnNodeCreatedBy = getUsernameFromUserKey(comment.commentBy);
      }
    }

    List<UserNodeType> parents = [];
    // if is reply
    if (commentProvider.commentTargetNodeType == DokiNodeType.comment) {
      parents.add(UserNodeType(
        nodeId: commentProvider.commentTargetId,
        nodeType: commentProvider.commentTargetNodeType.nodeType,
      ));
    }

    // add root node
    parents.add(UserNodeType(
      nodeId: commentProvider.rootNodeId,
      nodeType: commentProvider.rootNodeType.nodeType,
    ));

    // add user
    parents.add(UserNodeType(
      nodeId: commentProvider.rootNodeCreatedBy,
      nodeType: NodeType.user,
    ));

    final payload = UserCreateSecondaryNode(
      from: username,
      to: commentProvider.commentTargetNodeBy,
      nodeId: "will-be-updated-on-bloc-success",
      nodeType: NodeType.comment,
      parents: parents,
      mentions: content.mentions.toList(
        growable: false,
      ),
      replyOnNodeCreatedBy: replyOnNodeCreatedBy,
    );

    context.read<NodeCreateBloc>().add(CreateCommentEvent(
          commentDetails: commentDetails,
          client: context.read<WebsocketClientProvider>().client,
          remotePayload: payload,
        ));
  }

  Future<void> handleCropImage({
    required String path,
    required String extension,
  }) async {
    String croppedMedia = await getCroppedImage(
      path,
      context: context,
      location: ImageLocation.comment,
      compress: false,
    );
    if (croppedMedia.isEmpty) return;
    final mediaData = await File(croppedMedia).readAsBytes();
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
            return const SizedBox.shrink();
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
                          showError("Invalid media file selected.");
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
                  padding: const EdgeInsets.all(Constants.padding * 0.5),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                color: currTheme.primary,
                icon: const Icon(
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
              Builder(
                builder: (context) {
                  final commentProvider = context.watch<NodeCommentProvider>();

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
                        ? const LoadingWidget.nested()
                        : commentProvider.isReply
                            ? const Text("Reply")
                            : const Text("Add"),
                    style: FilledButton.styleFrom(),
                  );
                },
              ),
            ],
          );
        },
      );
    });
  }
}
