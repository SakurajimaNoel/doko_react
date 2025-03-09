import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/archive-query-input/archive_query_input.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';

abstract class InstantMessagingRepository {
  Future<bool> getUserInbox(InboxQueryInput inboxDetails);

  Future<bool> getUserArchive(ArchiveQueryInput archiveDetails);
}
