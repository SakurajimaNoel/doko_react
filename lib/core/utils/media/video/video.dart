import 'dart:io';

import 'package:doko_react/core/constants/constants.dart';
import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:media_data_extractor/media_data_extractor.dart';

enum VideoOrientation { landscape, portrait }

class VideoActions {
  static Future<String?> compressVideo(
    String videoPath, {
    bool trim = false,
    bool includeAudio = true,
    Duration limit = Constants.videoDurationContent,
  }) async {
    final double videoLimit = limit.inMilliseconds.toDouble();

    final duration = await getVideoDuration(videoPath);

    final editor = VideoEditorBuilder(
      videoPath: videoPath,
    );
    if (duration != null && duration > videoLimit) {
      editor.trim(
        startTimeMs: 0,
        endTimeMs: videoLimit.toInt(),
      );
    }

    editor.compress(
      resolution: VideoResolution.p1080,
    );
    final path = await editor.export();
    if (path != null) {
      File file = File(path);
      int sizeInBytes = await file.length();
      double sizeInKB = sizeInBytes / 1024;
      double sizeInMB = sizeInKB / 1024;

      print('File size: $sizeInBytes bytes');
      print('File size: $sizeInKB KB');
      print('File size: $sizeInMB MB');
    }
    return path;
  }

  static VideoOrientation getVideoOrientation(int width, int height) {
    if (width > height) return VideoOrientation.landscape;
    return VideoOrientation.portrait;
  }

  static Future<String?> getVideoThumbnail(String videoPath) async {
    try {
      final editor = VideoEditorBuilder(
        videoPath: videoPath,
      );

      return await editor.generateThumbnail(
        positionMs: 0,
        quality: 50,
      );
    } catch (err) {
      return null;
    }
  }

  static Future<void> cancelCurrentlyActiveVideoCompression() async {
    // await VideoCompress.cancelCompression();
  }

  static Future<double?> getVideoDuration(String videoPath) async {
    final mediaDataExtractorPlugin = MediaDataExtractor();
    final metas = await mediaDataExtractorPlugin.getVideoData(MediaDataSource(
      type: MediaDataSourceType.file,
      url: videoPath,
    ));
    return metas.tracks.firstOrNull?.duration?.toDouble();
  }
}
