part of 'image_filter_page.dart';

final _filterConfigurations = [
  NoneShaderConfiguration(),
  CGAColorspaceShaderConfiguration(),
  ColorInvertShaderConfiguration(),
  CrosshatchShaderConfiguration(),
  GrayscaleShaderConfiguration(),
  HalftoneShaderConfiguration(),
  LuminanceThresholdShaderConfiguration(),
  PixelationShaderConfiguration(),
  PosterizeShaderConfiguration(),
];

class ImageWithFilterInput {
  const ImageWithFilterInput({
    required this.data,
    required this.height,
    required this.width,
    required this.token,
  });

  final ByteBuffer data;
  final int width;
  final int height;
  final RootIsolateToken token;
}

Future<String> getImageWithFilter(ImageWithFilterInput details) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(details.token);

  final persistedImage = img.Image.fromBytes(
    width: details.width,
    height: details.height,
    bytes: details.data,
    numChannels: 4,
  );

  final directory = await getTemporaryDirectory();
  final output = File('${directory.path}/${generateUniqueString()}.jpeg');

  img.JpegEncoder encoder = img.JpegEncoder();
  final data = encoder.encode(persistedImage);
  await output.writeAsBytes(data);

  return output.path;
}
