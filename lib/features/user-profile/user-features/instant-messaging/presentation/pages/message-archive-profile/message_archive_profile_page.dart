import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/lottie/lottie_decoder.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_to_user_relation_widget.dart';
import 'package:doko_react/features/user-profile/user-features/widgets/user/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MessageArchiveProfilePage extends StatelessWidget {
  const MessageArchiveProfilePage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Constants.padding),
        child: Column(
          spacing: Constants.gap * 1.5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserWidget.preview(
              userKey: generateUserNodeKey(username),
            ),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: Constants.fontSize,
                fontWeight: FontWeight.w500,
              ),
              child: UserToUserRelationWidget.info(
                username: username,
              ),
            ),
            Container(
              height: Constants.height * 20,
              width: double.infinity,
              padding: EdgeInsets.all(Constants.padding),
              decoration: BoxDecoration(
                color: currTheme.primaryContainer,
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.radius)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading.left(
                    "No media files yet.",
                    size: Constants.heading4,
                  ),
                  Expanded(
                    child: Center(
                      child: _LottieMediaFile(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LottieMediaFile extends StatefulWidget {
  const _LottieMediaFile();

  @override
  State<_LottieMediaFile> createState() => _LottieMediaFileState();
}

class _LottieMediaFileState extends State<_LottieMediaFile>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose(); // Clean up controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;
    final color = currTheme.onPrimaryContainer;

    return Lottie.asset(
      "assets/media-animation.lottie",
      fit: BoxFit.contain,
      decoder: lottieDecoder,
      controller: controller,
      onLoaded: (composition) {
        controller.forward();
        controller.repeat();
      },
      delegates: LottieDelegates(
        values: [
          ValueDelegate.color(
            const ["**"],
            value: color,
          ),
          ValueDelegate.strokeColor(
            const ["**"],
            value: color,
          ),
        ],
      ),
    );
  }
}
