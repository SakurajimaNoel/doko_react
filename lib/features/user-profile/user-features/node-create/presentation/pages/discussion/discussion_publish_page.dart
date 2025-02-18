import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/widgets/content-media-selection-widget/content_media_selection_widget.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/discussion_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:flutter/material.dart';

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

  late final String discussionId;
  List<MediaContent> content = [];

  @override
  void initState() {
    super.initState();

    discussionId = generateUniqueString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish Discussion"),
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
                      info: mediaInfo,
                      nodeId: discussionId,
                      nodeType: DokiNodeType.discussion,
                      onMediaChange: (List<MediaContent> newMedia) {
                        content = newMedia;
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
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size(
                  Constants.buttonWidth,
                  Constants.buttonHeight,
                ),
              ),
              child: const Text("Upload"),
            ),
          ),
        ],
      ),
    );
  }
}
