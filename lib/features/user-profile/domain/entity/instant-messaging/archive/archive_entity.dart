import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';

/// nodes wrapper for archive entity
class ArchiveEntity extends Nodes {
  /// latest messages at start
  ArchiveEntity({
    required super.pageInfo,
    required super.items,
  });

  ArchiveEntity.empty() : super.empty();

  /// get items in group of days
  List<List<String>> groupByDays() {
    final UserGraph graph = UserGraph();

    List<List<String>> result = [];
    List<String> currentGroup = [];

    DateTime? groupDate;
    for (var item in items) {
      final messageEntity = graph.getValueByKey(item);
      if (messageEntity is! MessageEntity) continue;

      DateTime tempDate = messageEntity.message.sendAt;
      DateTime messageDate =
          DateTime(tempDate.year, tempDate.month, tempDate.day);

      if (groupDate == null || groupDate != messageDate) {
        if (currentGroup.isNotEmpty) {
          result.add(currentGroup);
        }

        groupDate = messageDate;
        currentGroup = [];
      }

      currentGroup.add(item);
    }

    return result;
  }
}
