/// it represent response from the data layer
/// when operation succeeds return instance of Resolve
/// when operation fails return instance of Reject
sealed class Result {}

/// this will accept <Type> as a result
final class Resolve<Type> extends Result {
  Resolve(this.value);

  final Type value;
}

/// error from data source
final class Reject extends Result {
  Reject(this.exception, {required this.message});

  final String message;
  final Object exception;
}
