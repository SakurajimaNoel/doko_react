import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/content-media-selection-widget/content_media_selection_widget.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/post_create_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({
    super.key,
  });

  @override
  State<CreatePostPage> createState() => CreatePostPageState();
}

class CreatePostPageState extends State<CreatePostPage> {
  bool videoProcessing = false;
  final List<String> postContentInfo = [
    "Keep your videos under ${Constants.videoDurationPost.inSeconds} seconds. Longer videos will be automatically trimmed.",
    "GIFs are typically designed to loop seamlessly, so cropping them might disrupt their intended animation.",
  ];

  late final String postId;

  List<MediaContent> content = [];

  @override
  void initState() {
    super.initState();

    postId = generateUniqueString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new post"),
      ),
      body: Column(
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
                    child: ContentMediaSelectionWidget(
                      info: postContentInfo,
                      nodeId: postId,
                      nodeType: DokiNodeType.post,
                      onMediaChange: (newMedia) {
                        content = newMedia;
                      },
                      onVideoProcessingChange: (bool isProcessing) {
                        videoProcessing = isProcessing;
                      },
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
                if (videoProcessing) {
                  showInfo("Please wait for video processing to finish.");
                  return;
                }

                Map<String, dynamic> data = {
                  "postDetails": PostPublishPageData(
                    content: content,
                    postId: postId,
                  ),
                };

                context.pushNamed(
                  RouterConstants.postPublish,
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
          ),
        ],
      ),
    );
  }
}
