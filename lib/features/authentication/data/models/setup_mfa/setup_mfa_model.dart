import 'package:doko_react/core/models/models.dart';
import 'package:doko_react/features/authentication/domain/entities/setup_mfa/setup_mfa_entity.dart';

class SetupMFAModel implements Models<SetupMFAEntity> {
  const SetupMFAModel({
    required this.setupUri,
    required this.sharedSecret,
  });

  final Uri setupUri;
  final String sharedSecret;

  @override
  SetupMFAEntity toEntity() {
    return SetupMFAEntity(
      setupUri: setupUri,
      sharedSecret: sharedSecret,
    );
  }
}
