import 'package:doko_react/core/global/storage/storage.dart';

/// use this class for any of the s3 resources
class StorageResource {
  const StorageResource._internal({
    required this.bucketPath,
    required this.accessURI,
  });

  /// used when cached media files are present
  /// or url is present
  const StorageResource.forGeneralResource({
    required this.bucketPath,
    required this.accessURI,
  });

  /// empty storage resource used inside [UserWidget]
  /// to handle when user data is not present
  const StorageResource.empty()
      : bucketPath = "",
        accessURI = "";

  final String bucketPath;
  final String accessURI;

  static Future<StorageResource> createStorageResource(
      String? bucketPath) async {
    if (bucketPath == null || bucketPath.isEmpty) {
      return StorageResource._internal(
        bucketPath: bucketPath ?? "",
        accessURI: "",
      );
    }
    String accessURI = await getDownloadUrlFromAWSPath(bucketPath);

    return StorageResource._internal(
      bucketPath: bucketPath,
      accessURI: accessURI,
    );
  }
}
