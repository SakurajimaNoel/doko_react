/// application exception is used to throw errors
/// that are not unknown or that have some message
/// to display to the user
class ApplicationException implements Exception {
  const ApplicationException({required this.reason});

  final String reason;
}
