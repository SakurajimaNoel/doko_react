import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/loading/small_loading_indicator.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
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

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: Constants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              showMessage(message);

              context.read<UserActionBloc>().add(
                    UserActionNewPostEvent(
                      postId: widget.postDetails.postId,
                    ),
                  );
              context.goNamed(RouterConstants.userFeed);
              return;
            }

            showMessage((state as NodeCreateError).message);
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
                  showMessage(message);
                  return;
                }

                context.pop();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(Constants.padding),
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: TextFormField(
                            enabled: !uploading,
                            controller: captionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Caption",
                              hintText: "Caption here...",
                            ),
                            autofocus: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: 12,
                            minLines: 5,
                            maxLength: Constants.postCaptionLimit,
                          ),
                        ),
                      );
                    }),
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
                                    "Your post needs either content or a caption. Please add at least one to proceed.";
                                showMessage(message);
                                return;
                              }

                              PostCreateInput postDetails = PostCreateInput(
                                username: username,
                                caption: captionController.text.trim(),
                                content: widget.postDetails.content,
                                postId: widget.postDetails.postId,
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
