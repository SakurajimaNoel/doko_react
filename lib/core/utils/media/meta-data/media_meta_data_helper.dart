import 'dart:io';

import 'package:image/image.dart' as img;

part 'media_meta_data_helper_lib.dart';

enum MediaTypeValue {
  image,
  video,
  thumbnail,
  unknown,
}

/// if unknown mime type returns null
String? getFileExtensionFromMimeType(String mimeType) {
  return _mimeToExtension[mimeType];
}

/// used with instant messaging preview
String getFileTypeFromPath(String path) {
  String extension = path.split('.').last.toLowerCase();

  if (_imageExtensions.contains(extension)) {
    return "image";
  }

  if (_videoExtensions.contains(extension)) {
    return "video";
  }

  if (_audioExtensions.contains(extension)) {
    return "audio";
  }

  return "file";
}

String? getFileExtensionFromFileName(String fileName) {
  if (fileName.isEmpty) return null;

  final int lastDot = fileName.lastIndexOf('.', fileName.length - 1);
  if (lastDot == -1) return null;

  final String extension = fileName.substring(lastDot + 1).toLowerCase();
  return ".$extension";
}

MediaTypeValue getMediaTypeFromPath(String path) {
  String extension = path.split('.').last.toLowerCase();

  if (_imageExtensions.contains(extension)) {
    return MediaTypeValue.image;
  }

  if (_videoExtensions.contains(extension)) {
    return MediaTypeValue.video;
  }

  return MediaTypeValue.unknown;
}

/// check if given webp is animated or not
Future<bool> isWebpAnimated(String path) async {
  final imageBytes = await File(path).readAsBytes();
  final image = img.WebPDecoder().decode(imageBytes);

  if (image != null) return image.numFrames > 1;

  return false;
}
