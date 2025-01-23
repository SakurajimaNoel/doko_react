import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

class InboxEntity extends GraphEntity {
  InboxEntity({
    required PageInfo pageInfo,
    required List<String> inboxItems,
  })  : _pageInfo = pageInfo,
        _empty = false,
        items = Set<String>.from(inboxItems);

  InboxEntity.empty()
      : _pageInfo = PageInfo.empty(),
        _empty = true,
        items = <String>{};

  PageInfo _pageInfo;
  Set<String> items;

  bool _empty = true;

  PageInfo get pageInfo => _pageInfo;

  bool get isEmpty => _empty;

  bool get isNotEmpty => !_empty;

  void updatePageInfo(PageInfo pageInfo) {
    _pageInfo = pageInfo;
    _empty = false;
  }

  void addItems(List<String> inboxItems) {
    items.addAll(inboxItems);
  }

  void reorder(String inboxItemKey) {
    items.remove(inboxItemKey);
    items.add(inboxItemKey);
  }
}
