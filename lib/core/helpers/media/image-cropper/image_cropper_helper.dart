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
  var currScheme = Theme.of(context).colorScheme;
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
        toolbarColor: currScheme.surface,
        toolbarWidgetColor: currScheme.onSurface,
        statusBarColor: currScheme.surface,
        backgroundColor: currScheme.surface,
        dimmedLayerColor: currScheme.surface.withOpacity(0.75),
        cropFrameColor: currScheme.onSurface,
        cropGridColor: currScheme.onSurface,
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
