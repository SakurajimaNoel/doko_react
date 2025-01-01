import 'package:doko_react/core/constants/constants.dart';
import 'package:video_compress/video_compress.dart';

enum VideoOrientation { landscape, portrait }

class VideoActions {
  static final double _videoLimit =
      Constants.videoDurationPost.inMilliseconds.toDouble();
  static const VideoQuality _quality = VideoQuality.DefaultQuality;

  static Future<String?> compressVideo(
    String videoPath, {
    bool trim = false,
    bool includeAudio = true,
    Duration limit = Constants.videoDurationPost,
  }) async {
    final double videoLimit = limit.inMilliseconds.toDouble();

    MediaInfo videoInfo = await VideoCompress.getMediaInfo(videoPath);
    double? videoDuration = videoInfo.duration;

    MediaInfo? compressedVideo;

    if (trim && videoDuration != null && videoDuration > videoLimit) {
      compressedVideo = await VideoCompress.compressVideo(
        videoPath,
        quality: _quality,
        deleteOrigin: true,
        startTime: 0,
        includeAudio: includeAudio,
        duration: ((videoDuration - videoLimit) / 1000).toInt(),
      );
    } else {
      compressedVideo = await VideoCompress.compressVideo(
        videoPath,
        quality: _quality,
        deleteOrigin: true,
        includeAudio: includeAudio,
      );
    }

    return compressedVideo?.path;
  }

  static VideoOrientation getVideoOrientation(int width, int height) {
    if (width > height) return VideoOrientation.landscape;
    return VideoOrientation.portrait;
  }

  static Future<String?> getVideoThumbnail(String videoPath) async {
    try {
      final thumbnailFile = await VideoCompress.getFileThumbnail(
        videoPath,
        quality: 50,
        position: -1,
      );

      return thumbnailFile.path;
    } catch (err) {
      return null;
    }
  }

  static Future<void> cancelCurrentlyActiveVideoCompression() async {
    await VideoCompress.cancelCompression();
  }
}
