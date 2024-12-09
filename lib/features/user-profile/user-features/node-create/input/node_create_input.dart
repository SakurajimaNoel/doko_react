import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';

class PostContent {
  const PostContent({
    required this.type,
    this.file,
    this.originalImage,
    required this.bucketPath,
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
}

class PostPublishPageData {
  const PostPublishPageData({
    required this.content,
    required this.postId,
  });

  final List<PostContent> content;
  final String postId;
}

class PostCreateInput {
  const PostCreateInput({
    required this.username,
    required this.caption,
    required this.content,
    required this.postId,
  });

  final String postId;
  final String username;
  final String caption;
  final List<PostContent> content;
}
