import 'dart:collection';

import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:flutter/cupertino.dart';

/// single source of truth for any node information
class UserGraph {
  final Map<String, ProfileEntity> _graph;

  // using hashmap because order preservation is not necessary
  UserGraph._internal() : _graph = HashMap();

  static UserGraph? _instance;

  factory UserGraph() {
    _instance ??= UserGraph._internal();
    return _instance!;
  }

  /// this will be used to get the instance in widgets
  /// to display information
  /// keys are user:username, post:post_id, comment:comment_id
  ProfileEntity? getValueByKey(String key) {
    return _graph[key];
  }

  bool containsKey(String key) {
    return _graph.containsKey(key);
  }

  /// each individual operation will handle updating the graph
  /// to support their use case and needs
  void updateValue(ValueSetter<Map<String, ProfileEntity>> func) {
    func(_graph);
  }
}

// functions to generate keys
String generateUserNodeKey(String username) {
  return "user:$username";
}

String generatePostNodeKey(String postId) {
  return "post:$postId";
}

String generateCommentNodeKey(String commentId) {
  return "comment:$commentId";
}
