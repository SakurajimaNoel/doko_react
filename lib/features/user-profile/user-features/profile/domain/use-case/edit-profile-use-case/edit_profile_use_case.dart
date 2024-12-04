import 'dart:async';

import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/helpers/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/helpers/uuid/uuid_helper.dart';
import 'package:doko_react/core/use-cases/use_cases.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/repository/profile_repository.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';

class EditProfileUseCase extends UseCases<bool, EditProfileInput> {
  EditProfileUseCase({required this.profileRepository});

  final ProfileRepository profileRepository;

  @override
  FutureOr<bool> call(EditProfileInput params) async {
    if (!params.validate()) {
      throw ApplicationException(
        reason: params.invalidateReason(),
      );
    }

    String bucketPath;
    if (params.newProfile == null) {
      bucketPath = "";
    } else if (params.currentProfile == params.newProfile) {
      bucketPath = params.currentProfile;
    } else {
      // new profile
      String? imageExtension = getFileExtensionFromFileName(params.newProfile!);
      if (imageExtension == null) {
        throw const ApplicationException(reason: "Invalid image selected.");
      }
      String imageString = generateUniqueString();
      bucketPath = "${params.userId}/profile/$imageString$imageExtension}";
    }

    return profileRepository.editUserProfile(params, bucketPath);
  }
}
