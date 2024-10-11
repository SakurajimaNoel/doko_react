import 'dart:async';

import 'package:doko_react/core/data/video.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:doko_react/core/provider/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayer extends StatefulWidget {
  final String path;

  const VideoPlayer({
    required super.key,
    required this.path,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final String _path;
  late final Key _key;
  late final VideoProvider _videoProvider;

  double _ratio = Constants.landscape;
  Timer? timer; // to get current video aspect ratio

  // video player
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    _path = widget.path;
    _key = widget.key!;

    _videoProvider = context.read<VideoProvider>();

    player
        .open(
      Media(_path),
    )
        .then((_) {
      _handleRatio();
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _handleRatio() {
    var width = player.state.width;
    var height = player.state.height;

    if (width == null || height == null) {
      this.timer ??= Timer.periodic(
          const Duration(
            milliseconds: 250,
          ), (t) {
        _handleRatio();
      });
      return;
    }

    if (VideoActions.getVideoOrientation(width, height) ==
        VideoOrientation.landscape) {
      if (_ratio != Constants.landscape) {
        setState(() {
          _ratio = Constants.landscape;
        });
      }
    } else {
      if (_ratio != Constants.portrait) {
        setState(() {
          _ratio = Constants.portrait;
        });
      }
    }

    final timer = this.timer;
    if (timer != null) timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var currTheme = Theme.of(context).colorScheme;
    Color primary = currTheme.primary;
    const double seekBarHeight = Constants.height * 0.2;

    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: (VisibilityInfo visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (_videoProvider.mute) {
          player.setVolume(0);
        } else {
          player.setVolume(100);
        }

        if (visiblePercentage >= 75) {
          player.play();
        } else {
          player.pause();
        }
      },
      child: MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
          seekBarPositionColor: currTheme.primary,
          seekBarThumbColor: currTheme.primary,
          seekBarColor: currTheme.onPrimary,
          seekBarThumbSize: 0,
          seekBarHeight: seekBarHeight,
        ),
        fullscreen: const MaterialVideoControlsThemeData(),
        child: Video(
          resumeUponEnteringForegroundMode: true,
          controller: controller,
          fit: BoxFit.contain,
          aspectRatio: _ratio,
          controls: (VideoState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialPlayOrPauseButton(
                  iconColor: primary,
                  iconSize: Constants.width,
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
                            _videoProvider.toggleAudio();

                            if (player.state.volume == 0) {
                              player.setVolume(100);
                            } else {
                              player.setVolume(0);
                            }
                          },
                          icon: StreamBuilder(
                            stream:
                                state.widget.controller.player.stream.volume,
                            builder: (context, volume) => Icon(
                              volume.data == 0
                                  ? Icons.volume_off
                                  : Icons.volume_up,
                              size: Constants.width,
                              color: primary,
                            ),
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
          },
          key: Key(_path),
        ),
      ),
    );
  }
}
