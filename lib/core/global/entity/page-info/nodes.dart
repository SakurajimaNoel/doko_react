import 'package:doko_react/core/global/entity/page-info/page_info.dart';

/// items are keys for userGraph that is stored in memory
/// keys are like user:username, post:post_id or comment:comment_id
class Nodes {
  const Nodes({
    required this.pageInfo,
    required this.items,
  });

  final PageInfo pageInfo;
  final List<String> items;
}
