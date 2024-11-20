class SetupMFAEntity {
  const SetupMFAEntity({
    required this.setupUri,
    required this.sharedSecret,
  });

  final String setupUri;
  final String sharedSecret;
}
