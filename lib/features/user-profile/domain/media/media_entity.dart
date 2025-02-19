import 'package:doko_react/core/global/cache/cache.dart';
import 'package:doko_react/core/global/entity/storage-resource/storage_resource.dart';
import 'package:doko_react/core/utils/media/meta-data/media_meta_data_helper.dart';

class MediaEntity {
  const MediaEntity({
    required this.mediaType,
    required this.resource,
  });

  final MediaTypeValue mediaType;
  final StorageResource resource;

  static Future<MediaEntity> createEntity(String bucketPath) async {
    final MediaTypeValue mediaType = getMediaTypeFromPath(bucketPath);

    if (mediaType == MediaTypeValue.video) {
      // check cache if present and return
      String? cachedPath = await getFileFromCache(bucketPath);
      if (cachedPath != null) {
        return MediaEntity(
          mediaType: mediaType,
          resource: StorageResource.forGeneralResource(
            bucketPath: bucketPath,
            accessURI: cachedPath,
          ),
        );
      }
    }

    final StorageResource resource =
        await StorageResource.createStorageResource(bucketPath);
    return MediaEntity(
      mediaType: mediaType,
      resource: resource,
    );
  }
}
