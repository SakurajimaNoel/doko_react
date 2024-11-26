part of 'post_entity.dart';

class PostContentEntity {
  const PostContentEntity({
    required this.mediaType,
    required this.resource,
  });

  final MediaTypeValue mediaType;
  final StorageResource resource;

  static Future<PostContentEntity> createEntity(String bucketPath) async {
    final MediaTypeValue mediaType = getMediaTypeFromPath(bucketPath);

    if (mediaType == MediaTypeValue.video) {
      // check cache if present and return
      String? cachedPath = await getFileFromCache(bucketPath);
      if (cachedPath != null) {
        return PostContentEntity(
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
    return PostContentEntity(
      mediaType: mediaType,
      resource: resource,
    );
  }
}
