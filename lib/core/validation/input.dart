abstract class Input {
  // returns true when input fields are valid
  bool validate();

  // returns a user friendly message to tell what the reason for invalidation is
  String invalidateReason();
}
