import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:image/image.dart';

Future<String> compressImage(String path) async {
  String? extension = getFileExtensionFromFileName(path);
  if (extension == null) return "";

  Image? image = await decodeImageFile(path);
  if (image == null) return "";
  if (image.hasAnimation) return path; // don't compress animated images

  int width;
  int height;

  if (image.width > image.height) {
    width = 800;
    height = (image.height / image.width * 800).round();
  } else {
    height = 800;
    width = (image.width / image.height * 800).round();
  }

  Image resizedImage = copyResize(
    image,
    width: width,
    height: height,
    maintainAspect: true,
  );

  String compressedPath = path.replaceFirst(extension, "_compressed.jpg");
  bool res = await encodeJpgFile(
    compressedPath,
    resizedImage,
    quality: 75,
  );

  return res ? compressedPath : "";
}
