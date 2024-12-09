import 'package:doko_react/core/constants/constants.dart';
import 'package:video_compress/video_compress.dart';

enum VideoOrientation { landscape, portrait }

class VideoActions {
  static final double _videoLimit =
      Constants.videoDuration.inMilliseconds.toDouble();
  static const VideoQuality _quality = VideoQuality.DefaultQuality;

  static Future<String?> compressVideo(String videoPath) async {
    MediaInfo videoInfo = await VideoCompress.getMediaInfo(videoPath);
    double? videoDuration = videoInfo.duration;

    MediaInfo? compressedVideo;

    if (videoDuration != null && videoDuration > _videoLimit) {
      compressedVideo = await VideoCompress.compressVideo(
        videoPath,
        quality: _quality,
        deleteOrigin: true,
        startTime: 0,
        duration: ((videoDuration - _videoLimit) / 1000).toInt(),
      );
    } else {
      compressedVideo = await VideoCompress.compressVideo(
        videoPath,
        quality: _quality,
        deleteOrigin: true,
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
