import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/media-widget/media_widget.dart';
import 'package:flutter/material.dart';

class MediaCarouselPage extends StatefulWidget {
  const MediaCarouselPage({
    super.key,
    required this.nodeKey,
  });

  final String nodeKey;

  @override
  State<MediaCarouselPage> createState() => _MediaCarouselPageState();
}

class _MediaCarouselPageState extends State<MediaCarouselPage> {
  late final nodeKey = widget.nodeKey;
  final UserGraph graph = UserGraph();

  @override
  Widget build(BuildContext context) {
    final media = graph.getValueByKey(nodeKey);

    if (media is! UserActionEntityWithMediaItems) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: StyledText.error(Constants.errorMessage),
        ),
      );
    }

    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: MediaWidget.page(
          nodeKey: nodeKey,
        ),
      ),
    );
  }
}
