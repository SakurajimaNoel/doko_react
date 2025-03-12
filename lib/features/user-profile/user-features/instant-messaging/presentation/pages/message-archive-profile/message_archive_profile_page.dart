import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/lottie/lottie_decoder.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
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
        padding: const EdgeInsets.all(Constants.padding),
        child: CompactBox(
          child: Column(
            spacing: Constants.gap * 1.5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserWidget.preview(
                userKey: generateUserNodeKey(username),
              ),
              DefaultTextStyle.merge(
                style: const TextStyle(
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
                padding: const EdgeInsets.all(Constants.padding),
                decoration: BoxDecoration(
                  color: currTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(Constants.radius),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Heading.left(
                      "Sent media files will appear here.",
                      size: Constants.fontSize,
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
    final color = currTheme.onSecondaryContainer;

    return Lottie.asset(
      "assets/media-animation.lottie",
      fit: BoxFit.contain,
      decoder: lottieDecoder,
      controller: controller,
      onLoaded: (composition) {
        controller.forward();
        controller.repeat();
      },
      width: Constants.width * 10,
      height: Constants.width * 10,
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
