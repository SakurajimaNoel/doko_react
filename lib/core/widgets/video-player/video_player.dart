import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/preferences/preferences_bloc.dart';
import 'package:doko_react/core/utils/extension/go_router_extension.dart';
import 'package:doko_react/core/utils/media/video/video.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayer extends StatefulWidget {
  final String path;
  final String bucketPath;

  const VideoPlayer({
    super.key,
    required this.path,
    required this.bucketPath,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final String path = widget.path;
  late final String bucketPath = widget.bucketPath;
  late final PreferencesBloc preferences;

  double ratio = Constants.landscape;
  Timer? timer; // to get current video aspect ratio

  // video player
  late Player player;
  late VideoController controller;
  bool loaded = false;

  @override
  void initState() {
    super.initState();

    preferences = context.read<PreferencesBloc>();
    player = Player();
    controller = VideoController(player);
    player
        .open(
      Media(path),
      play: false,
    )
        .then((_) {
      handleRatio();
    });
  }

  @override
  void dispose() {
    player.dispose();
    timer?.cancel();
    super.dispose();
  }

  void handleRatio() {
    try {
      var width = player.state.width;
      var height = player.state.height;

      if (width == null || height == null) {
        this.timer ??= Timer.periodic(
            const Duration(
              milliseconds: 250,
            ), (t) {
          handleRatio();
        });
        return;
      }

      if (VideoActions.getVideoOrientation(width, height) ==
          VideoOrientation.landscape) {
        if (ratio != Constants.landscape) {
          setState(() {
            ratio = Constants.landscape;
          });
        }
      } else {
        if (ratio != Constants.portrait) {
          setState(() {
            ratio = Constants.portrait;
          });
        }
      }

      loaded = true;
      final timer = this.timer;
      if (timer != null) timer.cancel();
    } on Exception {
      final timer = this.timer;
      if (timer != null) timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;
    Color primary = currTheme.primary;
    const double seekBarHeight = Constants.height * 0.2;
    final String routeName = GoRouter.of(context).currentRouteName ?? "";

    return VisibilityDetector(
      key: ObjectKey({
        "route-name": routeName,
        "bucket-path": bucketPath,
      }),
      onVisibilityChanged: (VisibilityInfo visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (!mounted) {
          player.pause();
          return;
        }

        try {
          if (preferences.state.audio) {
            player.setVolume(100);
          } else {
            player.setVolume(0);
          }

          if (visiblePercentage >= 75) {
            player.play();
          } else {
            player.pause();
          }
        } on Exception {
          // ignore exception
        }
      },
      child: MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
          speedUpOnLongPress: true,
          seekBarPositionColor: currTheme.primary,
          seekBarThumbColor: currTheme.primary,
          seekBarColor: currTheme.onPrimary,
          seekBarBufferColor:
              currTheme.onSecondaryContainer.withValues(alpha: 0.25),
          seekBarThumbSize: 0,
          seekBarHeight: seekBarHeight,
        ),
        fullscreen: MaterialVideoControlsThemeData(
          speedUpOnLongPress: true,
          speedUpFactor: 2,
          seekBarPositionColor: currTheme.primary,
          seekBarThumbColor: currTheme.primary,
          seekBarColor: currTheme.onPrimary,
          seekBarBufferColor:
              currTheme.onSecondaryContainer.withValues(alpha: 0.25),
          seekBarThumbSize: 0,
          seekBarHeight: seekBarHeight,
        ),
        child: Video(
          onEnterFullscreen: () async {
            Timer(
                const Duration(
                  milliseconds: 500,
                ), () {
              controller.player.play();
            });
          },
          onExitFullscreen: () async {
            controller.player.play();
          },
          fill: currTheme.surfaceContainer,
          resumeUponEnteringForegroundMode: true,
          controller: controller,
          fit: BoxFit.contain,
          aspectRatio: ratio,
          controls: (VideoState state) {
            bool fullScreen = state.isFullscreen();

            Widget child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialPlayOrPauseButton(
                      iconColor: primary,
                      iconSize: Constants.width,
                    ),
                    if (fullScreen)
                      MaterialFullscreenButton(
                        iconColor: primary,
                        iconSize: Constants.width * 1.125,
                      ),
                  ],
                ),
                const Spacer(),
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Constants.padding * 0.5,
                          ),
                          child: MaterialPositionIndicator(
                            style: TextStyle(
                              fontSize: Constants.smallFontSize * 0.75,
                              color: primary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (preferences.state.audio) {
                              player.setVolume(0);
                            } else {
                              player.setVolume(100);
                            }
                            preferences.add(PreferencesAudioToggleEvent());
                          },
                          iconSize: Constants.width,
                          color: primary,
                          icon: Builder(
                            builder: (BuildContext context) {
                              bool audio = context.select(
                                  (PreferencesBloc bloc) => bloc.state.audio);

                              return Icon(
                                audio ? Icons.volume_up : Icons.volume_off,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: seekBarHeight * 3,
                      child: MaterialSeekBar(),
                    ),
                  ],
                ),
              ],
            );

            return Material(
              color: Colors.transparent,
              child: GestureDetector(
                onLongPress: !fullScreen
                    ? null
                    : () {
                        controller.player.setRate(2.0);
                      },
                onLongPressEnd: !fullScreen
                    ? null
                    : (_) {
                        controller.player.setRate(1.0);
                      },
                child: InkWell(
                  onTap: () {
                    if (!loaded) return;

                    if (!fullScreen) {
                      state.toggleFullscreen();
                    } else {
                      controller.player.playOrPause();
                    }
                  },
                  child: fullScreen
                      ? SafeArea(
                          child: child,
                        )
                      : child,
                ),
              ),
            );
          },
          key: Key(path),
        ),
      ),
    );
  }
}
