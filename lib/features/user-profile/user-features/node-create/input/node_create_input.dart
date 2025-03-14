import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';

class MediaContent {
  const MediaContent({
    required this.type,
    this.file,
    this.originalImage,
    required this.bucketPath,
    this.thumbnail,
  })  : assert(
          type == MediaTypeValue.unknown || file != null,
          "File cannot be null for MediaTypeValue: $type.",
        ),
        assert(
          type != MediaTypeValue.image || originalImage != null,
          "Require original image file after cropping",
        );

  final MediaTypeValue type;
  final String? file;
  final String bucketPath;
  final String? originalImage;
  final String? thumbnail;
}
