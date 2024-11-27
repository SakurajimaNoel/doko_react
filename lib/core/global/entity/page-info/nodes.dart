import 'package:doko_react/core/global/entity/page-info/page_info.dart';

/// items are keys for userGraph that is stored in memory
/// keys are like user:username, post:post_id or comment:comment_id
class Nodes {
  Nodes({
    required PageInfo pageInfo,
    required this.items,
  }) : _pageInfo = pageInfo;

  Nodes.empty()
      : _pageInfo = PageInfo.empty(),
        items = [];

  void updatePageInfo(PageInfo pageInfo) {
    _pageInfo = pageInfo;
  }

  void addEntityItems(List<String> newItems) {
    items.addAll(newItems);
  }

  void addItem(String newItem) {
    items.insert(0, newItem);
  }

  void removeItem(String key) {
    items.remove(key);
  }

  PageInfo _pageInfo;
  final List<String> items;

  PageInfo get pageInfo => _pageInfo;
}
