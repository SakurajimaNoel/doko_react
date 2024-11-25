import 'package:equatable/equatable.dart';

class SetupMFAEntity extends Equatable {
  const SetupMFAEntity({
    required this.setupUri,
    required this.sharedSecret,
  });

  final Uri setupUri;
  final String sharedSecret;

  @override
  List<Object?> get props => [setupUri, sharedSecret];
}
