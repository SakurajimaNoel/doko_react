import 'dart:async';

import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/domain/repository/user_feed_repo.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/input/user_feed_input.dart';

class ContentUseCase extends UseCases<bool, UserFeedInput> {
  ContentUseCase({
    required this.repo,
  });

  final UserFeedRepo repo;

  @override
  FutureOr<bool> call(UserFeedInput params) async {
    return repo.getUserFeed(params);
  }
}
