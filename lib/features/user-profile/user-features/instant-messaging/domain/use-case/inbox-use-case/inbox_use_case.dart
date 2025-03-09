import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/domain/repository/instant_messaging_repository.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/input/inbox-query-input/inbox_query_input.dart';

class InboxUseCase extends UseCases<bool, InboxQueryInput> {
  InboxUseCase({
    required this.repository,
  });

  final InstantMessagingRepository repository;

  @override
  FutureOr<bool> call(InboxQueryInput params) async {
    return repository.getUserInbox(params);
  }
}
