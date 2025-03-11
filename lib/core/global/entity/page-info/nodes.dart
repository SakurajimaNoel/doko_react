import 'dart:collection';

import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

/// items are keys for userGraph that is stored in memory
/// keys are like user:username, post:post_id or comment:comment_id
class Nodes implements GraphEntity {
  Nodes({
    required PageInfo pageInfo,
    required this.items,
  })  : _pageInfo = pageInfo,
        _empty = false,
        _newInserts = HashSet();

  Nodes.empty()
      : _pageInfo = PageInfo.empty(),
        items = [],
        _empty = true,
        _newInserts = HashSet();

  void updatePageInfo(PageInfo pageInfo) {
    _pageInfo = pageInfo;
    _empty = false;
  }

  // add list at end
  void addEntityItems(List<String> newItems) {
    newItems.removeWhere((item) => _newInserts.contains(item));
    _newInserts.addAll(newItems);
    items.addAll(newItems);
  }

  // add to start
  void addItem(String newItem) {
    if (_newInserts.contains(newItem)) return;

    _newInserts.add(newItem);
    items.insert(0, newItem);
  }

  // add item at last
  void addItemAtLast(String newItem) {
    if (_newInserts.contains(newItem)) return;

    _newInserts.add(newItem);
    items.add(newItem);
  }

  void removeItem(String key) {
    if (_newInserts.contains(key)) {
      _newInserts.remove(key);
    }

    items.remove(key);
  }

  bool get isEmpty => _empty;

  bool get isNotEmpty => !_empty;

  PageInfo _pageInfo;
  final List<String> items;

  final Set<String> _newInserts;

  // used to identify if Nodes are fetched or is just empty
  bool _empty;

  PageInfo get pageInfo => _pageInfo;
}
