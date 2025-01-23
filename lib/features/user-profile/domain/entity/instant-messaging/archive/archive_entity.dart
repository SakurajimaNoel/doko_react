import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

class ArchiveEntity extends GraphEntity {
  ArchiveEntity({
    required this.archiveMessages,
    required this.currentSessionMessages,
  });

  // todo: handle messages in better way try SplayTreeSet
  Nodes archiveMessages;
  Set<String> currentSessionMessages;

  void addCurrentSessionMessages(String message) {
    currentSessionMessages.add(message);
  }
}
