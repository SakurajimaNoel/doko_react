import 'package:doko_react/features/user-profile/user-features/instant-messaging/data/remote-data-source/instant_messaging_remote_data_source.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/domain/repository/instant_messaging_repository.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/archive-query-input/archive_query_input.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';

class InstantMessagingRepositoryImpl implements InstantMessagingRepository {
  const InstantMessagingRepositoryImpl({
    required this.dataSource,
  });

  final InstantMessagingRemoteDataSource dataSource;

  @override
  Future<bool> getUserArchive(ArchiveQueryInput archiveDetails) {
    return dataSource.getUserArchive(archiveDetails);
  }

  @override
  Future<bool> getUserInbox(InboxQueryInput inboxDetails) {
    return dataSource.getUserInbox(inboxDetails);
  }
}
