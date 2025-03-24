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

String getFileSizeString(int bytes, {int decimals = 2}) {
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  double size = bytes.toDouble();

  while (size >= 1024 && i < suffixes.length - 1) {
    size /= 1024;
    i++;
  }

  return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
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

  img.JpegEncoder encoder = img.JpegEncoder(
    quality: 75,
  );
  final data = encoder.encode(persistedImage);
  await output.writeAsBytes(data);

  // int sizeInBytes = await output.length();
  // print('File size: ${getFileSizeString(sizeInBytes)}');

  return output.path;
}
