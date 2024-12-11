import 'dart:typed_data';

class CommentMedia {
  CommentMedia({
    this.data,
    required this.extension,
    this.uri,
  }) : assert(
            (extension != "url" && data != null) ||
                (extension == "uri" && uri != null),
            "Invalid comment media.");

  final Uint8List? data;
  final String extension;
  final String? uri;
}
