class SetupMFAEntity {
  const SetupMFAEntity({
    required this.setupUri,
    required this.sharedSecret,
  });

  final Uri setupUri;
  final String sharedSecret;
}
