import 'package:doko_react/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

part 'image_cropper_helper_lib.dart';

enum ImageLocation {
  profile,
  post,
  comment,
}

Future<CroppedFile?> getCroppedImage(
  String path, {
  required BuildContext context,
  required ImageLocation location,
}) async {
  var currTheme = Theme.of(context).colorScheme;
  CropAspectRatio ratio;

  switch (location) {
    case ImageLocation.profile:
      ratio = _profileRatio;
      break;
    case ImageLocation.post:
      ratio = _postRatio;
      break;
    case ImageLocation.comment:
      ratio = _commentRatio;
      break;
  }

  return await ImageCropper().cropImage(
    sourcePath: path,
    aspectRatio: ratio,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Profile Picture',
        toolbarColor: currTheme.surface,
        toolbarWidgetColor: currTheme.onSurface,
        statusBarColor: currTheme.surface,
        backgroundColor: currTheme.surface,
        dimmedLayerColor: currTheme.surface.withValues(alpha: 0.75),
        cropFrameColor: currTheme.onSurface,
        cropGridColor: currTheme.onSurface,
        cropFrameStrokeWidth: 6,
        cropGridStrokeWidth: 6,
      ),
      IOSUiSettings(
        title: 'Profile Picture',
      ),
      WebUiSettings(
        context: context,
      ),
    ],
  );
}
