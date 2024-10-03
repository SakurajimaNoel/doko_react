import 'package:doko_react/core/helpers/constants.dart';
import 'package:video_compress/video_compress.dart';

enum VideoOrientation { landscape, portrait }

class VideoActions {
  static final double _videoLimit =
      Constants.videoDuration.inMilliseconds.toDouble();
  static const VideoQuality _quality = VideoQuality.DefaultQuality;

  static Future<String?> handleVideo(String videoPath) async {
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
}
