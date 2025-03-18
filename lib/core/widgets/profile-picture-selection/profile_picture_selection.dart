import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/utils/media/image-cropper/image_cropper_helper.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';
import 'package:doko_react/core/widgets/image-picker/image_picker_widget.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/profile/profile_picture_filter.dart';
import 'package:flutter/material.dart';

class ProfilePictureSelection extends StatefulWidget {
  const ProfilePictureSelection({
    super.key,
    this.currentProfile,
    required this.onSelectionChange,
    required this.disabled,
  });

  final ValueSetter<String?> onSelectionChange;
  final StorageResource? currentProfile;
  final bool disabled;

  @override
  State<ProfilePictureSelection> createState() =>
      _ProfilePictureSelectionState();
}

class _ProfilePictureSelectionState extends State<ProfilePictureSelection> {
  String? selectedProfilePicture;

  /// used when editing profile
  bool removeProfile = false;

  void selectProfilePicture(String selectedImagePath) {
    setState(() {
      selectedProfilePicture = selectedImagePath;
      widget.onSelectionChange(selectedImagePath);
      removeProfile = false;
    });
  }

  void handleRemove() {
    selectedProfilePicture = null;
    widget.onSelectionChange(null);
    removeProfile = true;

    setState(() {});
  }

  Future<bool> checkAnimatedImage(String path) async {
    String? extension = getFileExtensionFromFileName(path);

    if (extension == ".gif") return true;
    if (extension == ".webp") return await isWebpAnimated(path);

    return false;
  }

  Future<void> onSelection(List<String> images) async {
    String selectedImage = images.first;

    // check if selected image is animated or not
    if (await checkAnimatedImage(selectedImage)) {
      setState(() {
        selectedProfilePicture = selectedImage;
      });
      return;
    }

    if (!mounted) return;
    String croppedImage = await getCroppedImage(
      selectedImage,
      context: context,
      location: ImageLocation.profile,
      compress: true,
    );

    if (croppedImage.isEmpty) return;
    selectProfilePicture(croppedImage);
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * (1 / Constants.profile);

        bool noPicture = removeProfile ||
            ((widget.currentProfile?.bucketPath.isEmpty ?? true) &&
                selectedProfilePicture == null);

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              getProfileImage(height, noPicture),
              ProfilePictureFilter.preview(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ImagePickerWidget(
                      onSelection: onSelection,
                      icon: const Icon(Icons.photo_camera),
                      disabled: widget.disabled,
                      disableImageCompression: true,
                    ),
                    if (!noPicture)
                      IconButton.filled(
                        onPressed: widget.disabled ? null : handleRemove,
                        icon: const Icon(Icons.delete),
                        color: currTheme.onError,
                        style: IconButton.styleFrom(
                          backgroundColor: currTheme.error,
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getProfileImage(double height, bool noPicture) {
    final currTheme = Theme.of(context).colorScheme;

    if (noPicture) {
      return Container(
        color: currTheme.surfaceContainerHighest,
        child: const Icon(
          Icons.person,
          size: Constants.height * 15,
        ),
      );
    }

    if (selectedProfilePicture != null) {
      return Image.file(
        File(selectedProfilePicture!),
        fit: BoxFit.cover,
        cacheHeight: Constants.editProfileCachedHeight,
      );
    }

    return CachedNetworkImage(
      memCacheHeight: Constants.profileCacheHeight,
      cacheKey: widget.currentProfile!.bucketPath,
      imageUrl: widget.currentProfile!.accessURI,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: LoadingWidget.small(),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      height: height,
    );
  }
}
