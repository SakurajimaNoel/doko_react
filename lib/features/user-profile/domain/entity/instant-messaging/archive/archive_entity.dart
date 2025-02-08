import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';

class ArchiveEntity implements GraphEntity {
  ArchiveEntity({
    required this.archiveMessages,
    required this.currentSessionMessages,
  });

  // todo: handle messages in better way try SplayTreeSet
  Nodes archiveMessages;

  // latest messages are at front
  Set<String> currentSessionMessages;

  void addCurrentSessionMessages(String message) {
    currentSessionMessages.add(message);
  }

  void removeMessage(String message) {
    if (currentSessionMessages.contains(message)) {
      currentSessionMessages.remove(message);
      return;
    }

    archiveMessages.removeItem(message);
  }
}
