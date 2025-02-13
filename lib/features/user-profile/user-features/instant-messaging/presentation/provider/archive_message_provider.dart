import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class ArchiveMessageProvider extends ChangeNotifier {
  ArchiveMessageProvider({
    required this.focusNode,
    required this.textColor,
    required this.backgroundColor,
    required this.selfBackgroundColor,
    required this.selfTextColor,
    required this.archiveUser,
    this.controller,
  }) : selectedMessages = HashSet();

  final FocusNode focusNode;
  final String archiveUser;
  final Set<String> selectedMessages;
  final Color selfTextColor;
  final Color selfBackgroundColor;
  final Color textColor;
  final Color backgroundColor;

  /// used to add reply to a message
  String? replyOn;

  final ListObserverController? controller;

  void addReply(String messageId) {
    replyOn = messageId;
    focusNode.requestFocus();
    notifyListeners();
  }

  void reset() {
    replyOn = null;

    notifyListeners();
  }

  void selectMessage(String messageId) {
    if (selectedMessages.contains(messageId)) {
      selectedMessages.remove(messageId);
    } else {
      selectedMessages.add(messageId);
    }

    notifyListeners();
  }

  void clearSelect() {
    selectedMessages.clear();
    notifyListeners();
  }

  bool isSelected(String messageId) {
    return selectedMessages.contains(messageId);
  }

  bool canShowMoreOptions() {
    return selectedMessages.isEmpty;
  }

  bool hasSelection() {
    return selectedMessages.isNotEmpty;
  }
}
