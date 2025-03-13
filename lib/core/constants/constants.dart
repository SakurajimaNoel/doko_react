import 'package:flutter/material.dart';

class Constants {
  static const double _root = 16;

  static const usernameLimit = 20;
  static final String usernameRegex =
      r"[\w][\w\d_.-]{2," + (usernameLimit - 1).toString() + r"}";
  static const bioLimit = 1 << 8;
  static const nameLimit = 30;

  static const String errorMessage = "Oops! Something went wrong.";
  static const Duration snackBarDuration = Duration(
    seconds: 3,
  );
  static const Duration notificationDuration = Duration(
    seconds: 3,
  );
  static const int backgroundDurationLimit = 30;
  static const Duration pingInterval = Duration(
    seconds: 10,
  );

  static const double padding = _root;
  static const double gap = _root;
  static const double radius = _root * 0.75;
  static const double avtarRadius = _root;

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
  static const Duration videoDurationPost = Duration(seconds: 300);
  static const Duration videoDurationStory = Duration(seconds: 30);
  static const double landscape = 16 / 9;
  static const double portrait = 9 / 16;

  // content
  static const int userTagLimit = 16;
  static const int mediaLimit = 1 << 4;
  static const double carouselDots = 6;
  static const double carouselActiveDotScale = 1.5;
  // when media files are used
  static const double contentWidth = 1;
  static const double contentHeight = 1;
  static const double contentContainer = (contentWidth /
      contentHeight); // for height use 1/contentContainer and for width use contentContainer

  // polls
  static const int pollOptionsLimit = 5;
  static const int pollMaxActiveDuration = 7;
  static const int pollQuestionSizeLimit = 1 << 8;
  static const int pollOptionSizeLimit = 1 << 7;

  // discussion
  static const int discussionTitleLimit = 1 << 8;
  static const int discussionTextLimit = 1 << 15;

  // post

  static const double actionWidth = _root * 2.5;
  static const double actionEdgeGap = _root * 0.125;
  static const int postCaptionLimit = 1 << 10;
  static const int postCaptionDisplayLimit = 1 << 7;

  static const double shrinkWidth = _root * 20;

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
  static const int commentContentDisplayLimit = 1 << 7;

  // intervals
  static const Duration userProfilePollInterval = Duration(
    minutes: 55,
  );

  // icon size
  static const double iconButtonSize = _root * 2.5;
  static const double dividerThickness = _root * 0.125;

  // scroll offset
  static const double scrollOffset = _root * 20;

  // instant messaging media
  static int archiveMedia = (_root * 25).round();
  static const int shareLimit = 1 << 6;
  static const int messageLimit = 1 << 14;
  static const int messageDisplayLimit = 1 << 9;
  static final RegExp emailRegexMessage =
      RegExp(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}");
  static final RegExp urlRegexMessage = RegExp(
      r"(?!@)(https?://)?([a-zA-Z0-9-]+\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}([/\w\-.~]*)?(\?[^\s#@]*)?(#[^\s@]*)?");
  static final RegExp phoneRegexMessage =
      RegExp(r"(\+?[0-9]{1,3})? ?[0-9]{3}[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}");
  static final Duration typingStatusEventDuration = const Duration(
    seconds: 3,
  ); // used for both firing end events and sending typing events
  static const int maxScrollDuration = 500; // in milliseconds
  static const String websocketNotConnectedError = "You are not connected";
  static const int batchSize = 25;

  // layout
  static const double compact = 600;
  static const double expanded = 840;
  static const double large = 1200;
}
