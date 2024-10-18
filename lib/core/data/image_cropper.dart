import 'package:doko_react/core/helpers/constants.dart';
import 'package:image_cropper/image_cropper.dart';

class CropAspectRatioProfile implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (Constants.profileWidth, Constants.profileHeight);

  @override
  String get name => 'profile';
}
