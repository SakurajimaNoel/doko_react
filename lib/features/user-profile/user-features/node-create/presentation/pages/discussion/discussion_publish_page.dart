import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/bullet-list/bullet_list.dart';
import 'package:doko_react/core/widgets/content-media-selection-widget/content_media_selection_widget.dart';
import 'package:doko_react/core/widgets/get-user-modal/get_user_modal.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
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
  final List<String> mediaInfo = [
    "You can add up to ${Constants.mediaLimit} media items per discussion.",
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

  List<Widget> createSelectedUserWidget() {
    if (usersTagged.isEmpty) {
      return [
        const SizedBox(
          height: Constants.height * 5,
          child: Center(
            child: Text(
              "No users tagged.",
            ),
          ),
        ),
      ];
    }

    List<Widget> widgets = [];
    for (String user in usersTagged) {
      String userKey = generateUserNodeKey(user);
      final widget = ListTile(
        leading: UserWidget.avtar(
          userKey: userKey,
        ),
        contentPadding: EdgeInsets.zero,
        title: UserWidget.name(
          userKey: userKey,
          baseFontSize: Constants.smallFontSize * 1.25,
          trim: 20,
        ),
        subtitle: UserWidget.username(
          userKey: userKey,
          baseFontSize: Constants.smallFontSize,
          trim: 20,
        ),
        trailing: IconButton(
          onPressed: () {
            setState(() {
              usersTagged.remove(user);
            });
          },
          icon: const Icon(
            Icons.close,
            color: Colors.redAccent,
          ),
        ),
      );

      widgets.add(widget);
    }

    return widgets;
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

              // todo: handle this
              context.read<UserActionBloc>().add(
                    UserActionNewDiscussionEvent(
                      discussionId: discussionId,
                      username: username,
                    ),
                  );

              // send to remote users
              // final client = context.read<WebsocketClientProvider>().client;
              // if (client != null && client.isActive) {
              //   // ignore if client is null
              //   UserCreateRootNode payload = UserCreateRootNode(
              //     from: username,
              //     id: widget.postDetails.postId,
              //     nodeType: NodeType.post,
              //   );
              //   client.sendPayload(payload);
              // }
              //
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
                        child: Container(
                          padding: const EdgeInsets.all(Constants.padding),
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            spacing: Constants.gap,
                            children: [
                              ContentMediaSelectionWidget(
                                info: mediaInfo,
                                nodeId: discussionId,
                                nodeType: DokiNodeType.discussion,
                                onMediaChange: (List<MediaContent> newMedia) {
                                  content = newMedia;
                                },
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: Constants.gap * 0.5,
                                children: [
                                  const Heading.left(
                                    "Tag your friends:",
                                    size: Constants.fontSize,
                                  ),
                                  BulletList(userTagInfo),
                                  FilledButton.tonalIcon(
                                    onPressed: () {
                                      GetUserModal.getUserModal(
                                        context: context,
                                        onDone: (selected) {
                                          setState(() {
                                            usersTagged = selected;
                                          });
                                        },
                                        selected: usersTagged,
                                      );
                                    },
                                    icon: const Icon(Icons.person),
                                    label: const Text("Tag friends"),
                                  ),
                                  ...createSelectedUserWidget(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Constants.padding),
                  child: FilledButton(
                    onPressed: uploading
                        ? null
                        : () {
                            // call bloc
                            final username = (context.read<UserBloc>().state
                                    as UserCompleteState)
                                .username;

                            final discussionDetails = widget.discussionDetails;
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
              ],
            );
          },
        ),
      ),
    );
  }
}
