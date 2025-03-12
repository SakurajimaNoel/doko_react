import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/content-media-selection-widget/content_media_selection_widget.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/widgets/users_tagged/users_tagged_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DiscussionPublishPage extends StatefulWidget {
  const DiscussionPublishPage({
    super.key,
    required this.discussionDetails,
  });

  final DiscussionPublishPageData discussionDetails;

  @override
  State<DiscussionPublishPage> createState() => _DiscussionPublishPageState();
}

class _DiscussionPublishPageState extends State<DiscussionPublishPage> {
  bool videoProcessing = false;

  final List<String> mediaInfo = [
    "Keep your videos under ${Constants.videoDurationPost.inSeconds} seconds. Longer videos will be automatically trimmed.",
  ];

  List<String> usersTagged = [];

  List<String> userTagInfo = [
    "You can tag up to ${Constants.userTagLimit} people on your discussion.",
    "Tagged discussion will also appear on your friends timeline.",
    "You can only tag your friends.",
  ];

  late final String discussionId;
  List<MediaContent> content = [];

  @override
  void initState() {
    super.initState();

    discussionId = generateUniqueString();
  }

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish Discussion"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<NodeCreateBloc>(),
        child: BlocConsumer<NodeCreateBloc, NodeCreateState>(
          listenWhen: (previousState, state) {
            return (state is NodeCreateSuccess || state is NodeCreateError);
          },
          listener: (context, state) {
            if (state is NodeCreateSuccess) {
              String message = "Successfully created new discussion.";
              showSuccess(message);

              context.read<UserActionBloc>().add(
                    UserActionNewDiscussionEvent(
                      discussionId: discussionId,
                      username: username,
                      usersTagged: usersTagged,
                    ),
                  );

              // send to remote users
              final client = context.read<WebsocketClientProvider>().client;
              if (client != null && client.isActive) {
                // ignore if client is null
                UserCreateRootNode payload = UserCreateRootNode(
                  from: username,
                  id: state.nodeId,
                  nodeType: NodeType.discussion,
                  usersTagged: usersTagged,
                );
                client.sendPayload(payload);
              }

              context.goNamed(RouterConstants.userFeed);
              return;
            }

            showError((state as NodeCreateError).message);
          },
          builder: (context, state) {
            bool uploading = state is NodeCreateLoading;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: CompactBox(
                          child: Container(
                            padding: const EdgeInsets.all(Constants.padding),
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              spacing: Constants.gap,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ContentMediaSelectionWidget(
                                  info: mediaInfo,
                                  nodeId: discussionId,
                                  nodeType: DokiNodeType.discussion,
                                  onMediaChange: (List<MediaContent> newMedia) {
                                    content = newMedia;
                                  },
                                  onVideoProcessingChange: (bool isProcessing) {
                                    videoProcessing = isProcessing;
                                  },
                                ),
                                UsersTaggedWidget(
                                  onRemove: (String user) {
                                    usersTagged.remove(user);
                                  },
                                  onSelected: (List<String> selected) {
                                    usersTagged = selected;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                CompactBox(
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.padding),
                    child: FilledButton(
                      onPressed: uploading
                          ? null
                          : () {
                              if (videoProcessing) {
                                showInfo(
                                    "Please wait for video processing to finish.");
                                return;
                              }
                              // call bloc
                              final username = (context.read<UserBloc>().state
                                      as UserCompleteState)
                                  .username;

                              final discussionDetails =
                                  widget.discussionDetails;
                              DiscussionCreateInput discussionInput =
                                  DiscussionCreateInput(
                                discussionId: discussionId,
                                username: username,
                                title: discussionDetails.title,
                                text: discussionDetails.text,
                                media: content,
                                usersTagged: usersTagged,
                              );

                              context
                                  .read<NodeCreateBloc>()
                                  .add(DiscussionCreateEvent(
                                    discussionDetails: discussionInput,
                                  ));
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          Constants.buttonWidth,
                          Constants.buttonHeight,
                        ),
                      ),
                      child: uploading
                          ? const SmallLoadingIndicator()
                          : const Text("Upload"),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
