import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/utils/uuid/uuid_helper.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/complete-profile/domain/repository/complete_profile_repository.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';

class CompleteProfileUseCase extends UseCases<bool, CompleteProfileInput> {
  CompleteProfileUseCase({required this.completeProfile});

  final CompleteProfileRepository completeProfile;

  @override
  FutureOr<bool> call(CompleteProfileInput params) {
    if (!params.validate()) {
      throw ApplicationException(reason: params.invalidateReason());
    }

    /// generate bucket path for profile image
    /// path is: user_id/profile/{random}.jpg
    String bucketPath;
    String? imageExtension = getFileExtensionFromFileName(params.profilePath);
    if (imageExtension == null) {
      throw const ApplicationException(reason: "Invalid image selected.");
    }
    String imageString = generateUniqueString();
    bucketPath = "${params.userId}/profile/$imageString$imageExtension}";

    return completeProfile.completeUserProfile(params, bucketPath);
  }
}
