import 'package:flutter/material.dart';

class PostCarouselIndicatorProvider extends ChangeNotifier {
  PostCarouselIndicatorProvider({
    required this.currentItem,
    required this.width,
  });

  int currentItem;
  double width;

  void updateCurrentItem(int index) {
    currentItem = index;

    notifyListeners();
  }

  void updateWidth(double width) {
    this.width = width;
    notifyListeners();
  }
}
