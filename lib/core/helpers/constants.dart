import 'package:flutter/material.dart';

class Constants {
  static const double _root = 16;

  static const double padding = _root;
  static const double gap = _root;
  static const double radius = _root;
  static const double width = _root;
  static const double height = _root;

  static const double buttonHeight = _root * 3;
  static const double buttonWidth = double.infinity;
  static const double buttonLoaderWidth = _root * 1.5;

  static const double fontSize = _root;
  static const double smallFontSize = fontSize * 0.75; // 12px
  static const double largeFontSize = fontSize * 1.25; // 20px
  static const double heading1 = fontSize * 3; // 48px
  static const double heading2 = fontSize * 2; // 32px
  static const double heading3 = fontSize * 1.75; // 28px
  static const double heading4 = fontSize * 1.5; // 24px

  static const double appBarHeight = kToolbarHeight;
  static const double expandedAppBarHeight = _root * 22.5;

  // images
  static int postCacheHeight = (_root * 50).round();
  static int profileCacheHeight = (_root * 75).round();
  static int thumbnailCacheHeight = (_root * 5).round();
  static int editProfileCachedHeight = (_root * 75).round();

  // video
  static Duration videoDuration = const Duration(seconds: 90);
  static const double landscape = 16 / 9;
  static const double portrait = 9 / 16;

  // post
  static const double postContainer =
      4 / 3; // for height use 1/postContainer and for width use postContainer
  static const double actionWidth = _root * 2.5;
  static const double actionEdgeGap = _root * 0.125;
  static const int postLimit = 10;
}
