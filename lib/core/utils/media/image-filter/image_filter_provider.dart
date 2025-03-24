import 'package:flutter/material.dart';
import 'package:flutter_image_filters/flutter_image_filters.dart';

class ImageFilterProvider extends ChangeNotifier {
  ImageFilterProvider({
    required this.configuration,
    required this.selected,
    this.exporting = false,
  });

  ShaderConfiguration configuration;
  int selected;
  bool exporting;

  void updateConfiguration(ShaderConfiguration config, int index) {
    if (exporting) return;

    configuration = config;
    selected = index;

    notifyListeners();
  }

  void export() {
    exporting = true;
    notifyListeners();
  }
}
