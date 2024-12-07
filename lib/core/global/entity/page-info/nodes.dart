import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

/// items are keys for userGraph that is stored in memory
/// keys are like user:username, post:post_id or comment:comment_id
class Nodes extends GraphEntity {
  Nodes({
    required PageInfo pageInfo,
    required this.items,
  })  : _pageInfo = pageInfo,
        _empty = false;

  Nodes.empty()
      : _pageInfo = PageInfo.empty(),
        items = [],
        _empty = true;

  void updatePageInfo(PageInfo pageInfo) {
    _pageInfo = pageInfo;
    _empty = false;
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

  bool get isEmpty => _empty;

  PageInfo _pageInfo;
  final List<String> items;

  // used to identify if Nodes are fetched or is just empty
  bool _empty;

  PageInfo get pageInfo => _pageInfo;
}
