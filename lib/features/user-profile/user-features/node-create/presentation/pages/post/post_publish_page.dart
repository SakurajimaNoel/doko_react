import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/bullet-list/bullet_list.dart';
import 'package:doko_react/core/widgets/get-user-modal/get_user_modal.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostPublishPage extends StatefulWidget {
  const PostPublishPage({
    super.key,
    required this.postDetails,
  });

  final PostPublishPageData postDetails;

  @override
  State<PostPublishPage> createState() => _PostPublishPageState();
}

class _PostPublishPageState extends State<PostPublishPage> {
  final TextEditingController captionController = TextEditingController();
  List<String> usersTagged = [];

  List<String> userTagInfo = [
    "You can tag up to ${Constants.userTagLimit} people on your post.",
    "Tagged post will also appear on your friends timeline.",
    "You can only tag your friends.",
  ];

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
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
        title: const Text("Publish post"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<NodeCreateBloc>(),
        child: BlocConsumer<NodeCreateBloc, NodeCreateState>(
          listenWhen: (previousState, state) {
            return (state is NodeCreateSuccess || state is NodeCreateError);
          },
          listener: (context, state) {
            if (state is NodeCreateSuccess) {
              String message = "Successfully created new post.";
              showSuccess(message);

              context.read<UserActionBloc>().add(
                    UserActionNewPostEvent(
                      postId: widget.postDetails.postId,
                      username: username,
                    ),
                  );

              // send to remote users
              final client = context.read<WebsocketClientProvider>().client;
              if (client != null && client.isActive) {
                // ignore if client is null
                UserCreateRootNode payload = UserCreateRootNode(
                  from: username,
                  id: widget.postDetails.postId,
                  nodeType: NodeType.post,
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

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (bool didPop, var result) {
                if (didPop) return;

                if (uploading) {
                  String message =
                      "Your post is almost there! Please let it finish uploading before navigating away.";
                  showInfo(message);
                  return;
                }

                context.pop();
              },
              child: Column(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  enabled: !uploading,
                                  controller: captionController,
                                  decoration: const InputDecoration(
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(),
                                    labelText: "Caption",
                                    hintText: "Caption here...",
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 12,
                                  minLines: 5,
                                  maxLength: Constants.postCaptionLimit,
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
                              final username = (context.read<UserBloc>().state
                                      as UserCompleteState)
                                  .username;

                              final String caption =
                                  captionController.text.trim();

                              if (caption.isEmpty &&
                                  widget.postDetails.content.isEmpty) {
                                String message =
                                    "Your post needs either content or a caption.\nPlease add at least one to proceed.";
                                showError(message);
                                return;
                              }

                              PostCreateInput postDetails = PostCreateInput(
                                username: username,
                                caption: captionController.text.trim(),
                                content: widget.postDetails.content,
                                postId: widget.postDetails.postId,
                                usersTagged: usersTagged,
                              );

                              context
                                  .read<NodeCreateBloc>()
                                  .add(PostCreateEvent(
                                    postDetails: postDetails,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
