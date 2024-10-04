import 'dart:async';

import 'package:doko_react/core/data/video.dart';
import 'package:doko_react/core/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayer extends StatefulWidget {
  final String path;

  const VideoPlayer({
    super.key,
    required this.path,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late final String _path;

  double _ratio = Constants.landscape;
  Timer? timer; // to get current video aspect ratio

  // video player
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    _path = widget.path;

    player
        .open(
      Media(_path),
      play: false,
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

    return MaterialVideoControlsTheme(
      normal: MaterialVideoControlsThemeData(
        buttonBarButtonColor: currTheme.primary,
        automaticallyImplySkipNextButton: false,
        automaticallyImplySkipPreviousButton: false,
        primaryButtonBar: [
          const MaterialPlayOrPauseButton(
            iconSize: 24,
          ),
        ],
        bottomButtonBar: [
          const MaterialPositionIndicator(
            style: TextStyle(
              fontSize: 0,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              if (player.state.volume == 0) {
                // TODO: handle current video volume
                player.setVolume(50);
              } else {
                player.setVolume(0);
              }
            },
            icon: StreamBuilder(
              stream: player.stream.volume,
              builder: (context, volume) {
                return Icon(
                  volume.data == 0 ? Icons.volume_off : Icons.volume_up,
                  size: 16,
                  color: currTheme.primary,
                );
              },
            ),
          )
        ],
        seekBarPositionColor: currTheme.primary,
        seekBarThumbColor: currTheme.primary,
        seekBarColor: currTheme.onPrimary,
        seekBarThumbSize: 8,
        seekBarHeight: 3,
      ),
      fullscreen: const MaterialVideoControlsThemeData(),
      child: Video(
        controller: controller,
        fit: BoxFit.contain,
        aspectRatio: _ratio,
        controls: MaterialVideoControls,
        key: Key(_path),
      ),
    );
  }
}
