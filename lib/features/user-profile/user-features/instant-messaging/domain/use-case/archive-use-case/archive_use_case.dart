import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/domain/repository/instant_messaging_repository.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/archive-query-input/archive_query_input.dart';

class ArchiveUseCase extends UseCases<bool, ArchiveQueryInput> {
  ArchiveUseCase({
    required this.repository,
  });

  final InstantMessagingRepository repository;

  @override
  FutureOr<bool> call(ArchiveQueryInput params) async {
    return repository.getUserArchive(params);
  }
}
