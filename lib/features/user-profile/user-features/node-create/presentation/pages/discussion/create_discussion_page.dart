import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/bullet-list/bullet_list.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/core/widgets/markdown-display-widget/markdown_display_widget.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateDiscussionPage extends StatefulWidget {
  const CreateDiscussionPage({super.key});

  @override
  State<CreateDiscussionPage> createState() => _CreateDiscussionPageState();
}

class _CreateDiscussionPageState extends State<CreateDiscussionPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController textController = TextEditingController();

  final titleFocusNode = FocusNode();
  final textFocusNode = FocusNode();

  final List<String> discussionInfo = [
    "You can also use 'markdown' for better formatting of discussion content.",
    "@md: See the basic [markdown syntax](https://www.markdownguide.org/basic-syntax/) and [cheat sheet.](https://www.markdownguide.org/cheat-sheet/)",
    "You can mention user profile like: [user](doki@user:username).",
  ];

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start new discussion"),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: Constants.padding,
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: currTheme.surface,
                    title: const Heading(
                      "Discussion text preview",
                      size: Constants.heading3,
                    ),
                    insetPadding: const EdgeInsets.all(
                      Constants.padding,
                    ),
                    scrollable: true,
                    contentPadding: const EdgeInsets.all(
                      Constants.padding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Constants.radius,
                      ),
                    ),
                    content: MarkdownDisplayWidget(
                      data: textController.text,
                    ),
                    actionsPadding: const EdgeInsets.all(
                      Constants.padding * 0.625,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("Preview"),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, var result) {
          if (didPop) return;

          if (textFocusNode.hasFocus || titleFocusNode.hasFocus) {
            FocusManager.instance.primaryFocus?.unfocus();
            return;
          }

          context.pop();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Constants.gap * 0.5,
                        children: [
                          const Heading.left(
                            "Just a heads up:",
                            size: Constants.fontSize,
                          ),
                          BulletList(discussionInfo),
                          const SizedBox(
                            height: Constants.gap * 0.5,
                          ),
                          TextField(
                            focusNode: titleFocusNode,
                            controller: titleController,
                            decoration: const InputDecoration(
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                              labelText: "*Title",
                              hintText: "Title...",
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            minLines: 1,
                            maxLength: Constants.discussionTitleLimit,
                          ),
                          const SizedBox(
                            height: Constants.gap * 0.25,
                          ),
                          TextField(
                            focusNode: textFocusNode,
                            controller: textController,
                            decoration: const InputDecoration(
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                              labelText: "Text",
                              hintText: "Text or markdown...",
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: 16,
                            minLines: 8,
                            maxLength: Constants.discussionTextLimit,
                          )
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
                onPressed: () {
                  String title = titleController.text.trim();
                  String text = textController.text.trim();
                  if (title.isEmpty || title.length < 3) {
                    showError(
                        "Title is required and should be minimum of 3 characters.");
                    return;
                  }

                  Map<String, dynamic> data = {
                    "discussionDetails": DiscussionPublishPageData(
                      title: title,
                      text: text,
                    ),
                  };

                  context.pushNamed(
                    RouterConstants.discussionPublish,
                    extra: data,
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(
                    Constants.buttonWidth,
                    Constants.buttonHeight,
                  ),
                ),
                child: const Text("Continue"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
