import 'package:giphy_get/giphy_get.dart';

String? getValidGiphyURI(GiphyGif? gif) {
  if (gif == null) return null;

  if (gif.images == null) return null;

  final propertiesOrder = [
    gif.images!.downsized?.url,
    gif.images!.downsizedStill?.url,
    gif.images!.downsizedLarge?.url,
    gif.images!.w480Still?.url,
    gif.images!.originalStill.url,
    gif.images!.original?.url,
  ];

  return propertiesOrder.firstWhere((url) => url != null, orElse: () => null);
}
