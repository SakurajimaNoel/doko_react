import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/widgets/users_tagged/users_tagged_widget.dart';
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

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
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
                      usersTagged: usersTagged,
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
