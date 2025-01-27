import 'dart:collection';

import 'package:flutter/material.dart';

class ArchiveMessageProvider extends ChangeNotifier {
  ArchiveMessageProvider({
    required this.focusNode,
    required this.textColor,
    required this.backgroundColor,
    required this.selfBackgroundColor,
    required this.selfTextColor,
    required this.archiveUser,
  }) : selectedMessages = HashSet();

  final FocusNode focusNode;
  final String archiveUser;
  final Set<String> selectedMessages;
  final Color selfTextColor;
  final Color selfBackgroundColor;
  final Color textColor;
  final Color backgroundColor;

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
