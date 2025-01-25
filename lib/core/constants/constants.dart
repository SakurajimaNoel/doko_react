import 'package:flutter/material.dart';

class Constants {
  static const double _root = 16;

  static const usernameLimit = 20;
  static final String usernameRegex =
      r"[\w][\w\d_.-]{2," + (usernameLimit - 1).toString() + r"}";

  static const String errorMessage = "Oops! Something went wrong.";
  static const Duration snackBarDuration = Duration(
    seconds: 3,
  );
  static const Duration notificationDuration = Duration(
    seconds: 3,
  );

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
  static const double profileWidth = 1;
  static const double profileHeight = 1;
  static const double profile = (profileWidth / profileHeight);

  // images
  static int postCacheHeight = (_root * 50).round();
  static int profileCacheHeight = (_root * 75).round();
  static int thumbnailCacheHeight = (_root * 5).round();
  static int editProfileCachedHeight = (_root * 75).round();

  // video
  static const Duration videoDurationPost = Duration(seconds: 90);
  static const Duration videoDurationStory = Duration(seconds: 30);
  static const double landscape = 16 / 9;
  static const double portrait = 9 / 16;

  // post
  static const double postWidth = 1;
  static const double postHeight = 1;
  static const double postContainer = (postWidth /
      postHeight); // for height use 1/postContainer and for width use postContainer
  static const double actionWidth = _root * 2.5;
  static const double actionEdgeGap = _root * 0.125;
  static const int postLimit = 10;
  static const int postCaptionLimit = 1024;
  static const int postCaptionDisplayLimit = 128;
  static const double carouselDots = 6;
  static const double carouselActiveDotScale = 1.5;
  static const double postMetadataWidth = _root * 20;

  // profile
  static const double sliverPersistentHeaderHeight = 50;
  static const double sliverBorder = 1.5;
  static const double userRelationWidth = (_root * 16) + (padding * 2); // 268

  // comment
  static const double commentWidth = 3;
  static const double commentHeight = 2;
  static const double commentContainer = (commentWidth / commentHeight);
  static const String zeroWidthSpace = "\u200B";
  static const double commentOverlayHeight = _root * 5;
  static const int commentContentDisplayLimit = 128;

  // intervals
  static const Duration userProfilePollInterval = Duration(
    minutes: 55,
  );

  // icon size
  static const double iconButtonSize = _root * 2.5;
  static const double dividerThickness = _root * 0.125;

  // scroll offset
  static const double scrollOffset = _root * 25;

  // instant messaging media
  static int archiveMedia = (_root * 25).round();
  static const int shareLimit = 10;
}
