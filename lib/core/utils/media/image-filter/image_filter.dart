import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/utils/media/image/image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<String> addImageFilter(
  String path, {
  required BuildContext context,
}) async {
  String? imageWithFilter = await context.pushNamed(
    RouterConstants.imageFilter,
    pathParameters: {
      "image": path,
    },
  );

  if (imageWithFilter == null) return "";

  if (imageWithFilter.isEmpty) {
    return compute(compressImage, path);
  }

  return compute(compressImage, imageWithFilter);
}
