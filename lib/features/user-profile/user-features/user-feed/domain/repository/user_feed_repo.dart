import 'package:doko_react/features/user-profile/user-features/user-feed/input/user_feed_input.dart';

abstract class UserFeedRepo {
  Future<bool> getUserFeed(UserFeedInput details);
}
