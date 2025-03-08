import 'package:doko_react/core/global/entity/page-info/nodes.dart';

/// this defines reorder to make the given inbox item at first
class InboxEntity extends Nodes {
  InboxEntity({
    required super.pageInfo,
    required super.items,
  });

  InboxEntity.empty() : super.empty();

  /// latest item will be at the end
  /// use items.length - 1 - currInd to get corresponding index in sorted order based on time
  void reorder(String inboxItemKey) {
    items.remove(inboxItemKey);
    items.add(inboxItemKey);
  }
}
