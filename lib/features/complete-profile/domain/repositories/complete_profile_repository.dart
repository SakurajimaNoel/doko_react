import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';

abstract class CompleteProfileRepository {
  Future<bool> checkUsernameAvailability(UsernameInput usernameInput);
}
