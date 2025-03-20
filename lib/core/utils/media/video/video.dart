import 'package:doko_react/core/constants/constants.dart';
import 'package:easy_video_editor/easy_video_editor.dart';

enum VideoOrientation { landscape, portrait }

class VideoActions {
  static Future<String?> compressVideo(
    String videoPath, {
    bool trim = false,
    bool includeAudio = true,
    Duration limit = Constants.videoDurationContent,
  }) async {
    final double videoLimit = limit.inMilliseconds.toDouble();

    final editor = VideoEditorBuilder(
      videoPath: videoPath,
    );
    final duration = await getVideoDuration(editor);
    if (duration != null && duration > videoLimit) {
      editor.trim(
        startTimeMs: 0,
        endTimeMs: videoLimit.toInt(),
      );
    }

    editor.compress(
      resolution: VideoResolution.p1080,
    );
    return await editor.export();
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
    await VideoEditorBuilder.cancel();
  }

  static Future<double?> getVideoDuration(VideoEditorBuilder editor) async {
    var details = await editor.getVideoMetadata();
    return details.duration.toDouble();
  }
}
