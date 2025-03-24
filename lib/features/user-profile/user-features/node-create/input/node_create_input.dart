import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';

abstract class MediaContent {
  MediaTypeValue get mediaType;
  String get bucketPath;
  String get mediaFile;
  bool get animated;
}

class ImageContent implements MediaContent {
  const ImageContent({
    required this.mediaFile,
    required this.bucketPath,
    required this.originalImage,
    this.animated = false,
  }) : mediaType = MediaTypeValue.image;

  @override
  final MediaTypeValue mediaType;

  @override
  final String mediaFile;

  @override
  final String bucketPath;

  final String originalImage;

  @override
  final bool animated;
}

class VideoContent implements MediaContent {
  const VideoContent({
    required this.mediaFile,
    required this.bucketPath,
    required this.thumbnail,
  })  : mediaType = MediaTypeValue.video,
        animated = true;

  @override
  final MediaTypeValue mediaType;

  @override
  final String mediaFile;

  @override
  final String bucketPath;

  @override
  final bool animated;

  final String? thumbnail;
}

class VideoThumbnailContent implements MediaContent {
  const VideoThumbnailContent({
    required this.mediaFile,
  })  : animated = true,
        mediaType = MediaTypeValue.thumbnail;

  @override
  final MediaTypeValue mediaType;

  @override
  final String mediaFile;

  @override
  final bool animated;

  @override
  String get bucketPath => throw const ApplicationException(
        reason: "Thumbnail doesn't require bucket path",
      );
}

class VideoUnknownThumbnailContent implements MediaContent {
  const VideoUnknownThumbnailContent()
      : animated = true,
        mediaType = MediaTypeValue.unknown;

  @override
  final MediaTypeValue mediaType;

  @override
  final bool animated;

  @override
  String get bucketPath => throw const ApplicationException(
        reason: "Thumbnail doesn't require bucket path",
      );

  @override
  String get mediaFile => throw const ApplicationException(
        reason: "Thumbnail was not generated",
      );
}
