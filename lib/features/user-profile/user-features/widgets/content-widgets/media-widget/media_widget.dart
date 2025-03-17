import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/core/widgets/video-player/video_player.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/media/media_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/content-widgets/media-widget/provider/media_carousel_indicator_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

part "media_widget_carousel.dart";
part "media_widget_page_carousel.dart";

class MediaWidget extends StatelessWidget {
  const MediaWidget({
    super.key,
    required this.nodeKey,
    this.width,
  }) : page = false;

  const MediaWidget.page({
    super.key,
    required this.nodeKey,
    this.width,
  }) : page = true;

  final String nodeKey;
  final double? width;
  final bool page;

  @override
  Widget build(BuildContext context) {
    final graph = UserGraph();
    final node = graph.getValueByKey(nodeKey);

    if (node is! UserActionEntityWithMediaItems) {
      return const SizedBox(
        height: Constants.height * 5,
        child: Center(
          child: StyledText.error(Constants.errorMessage),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = width ?? constraints.maxWidth;

        if (page) {
          return _MediaContentPage(
            nodeKey: nodeKey,
          );
        }

        return ChangeNotifierProvider(
          create: (_) => MediaCarouselIndicatorProvider(
            currentItem: node.currDisplay,
            width: maxWidth,
          ),
          child: _MediaContent(
            nodeKey: nodeKey,
          ),
        );
      },
    );
  }
}
