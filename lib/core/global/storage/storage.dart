import 'dart:typed_data';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:aws_common/vm.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';

final StorageCategory _storage = Amplify.Storage;

Future<String> getDownloadUrlFromAWSPath(String bucketPath) async {
  try {
    final result = await _storage
        .getUrl(
          path: StoragePath.fromString(bucketPath),
          options: const StorageGetUrlOptions(
            pluginOptions: S3GetUrlPluginOptions(
              expiresIn: Duration(
                minutes: 60,
              ),
            ),
          ),
        )
        .result;
    return result.url.toString();
  } on StorageException catch (e) {
    return throw ApplicationException(reason: e.message);
  } catch (e) {
    rethrow;
  }
}

Future<String> uploadFileToAWSByPath(String filePath, String bucketPath) async {
  try {
    await _storage
        .uploadFile(
          localFile: AWSFilePlatform.fromPath(filePath),
          path: StoragePath.fromString(bucketPath),
        )
        .result;
    return bucketPath;
  } on StorageException catch (e) {
    return throw ApplicationException(reason: e.message);
  } catch (e) {
    rethrow;
  }
}

Future<bool> uploadFileBytesToAWSByPath(
    Uint8List data, String bucketPath) async {
  try {
    await _storage
        .uploadFile(
          localFile: AWSFile.fromData(data),
          path: StoragePath.fromString(bucketPath),
        )
        .result;
    return true;
  } on StorageException catch (e) {
    return throw ApplicationException(reason: e.message);
  } catch (e) {
    rethrow;
  }
}

Future<bool> deleteFileFromAWSByPath(String bucketPath) async {
  try {
    if (bucketPath.isEmpty) return true;

    await _storage
        .remove(
          path: StoragePath.fromString(bucketPath),
        )
        .result;

    return true;
  } on StorageException catch (e) {
    return throw ApplicationException(reason: e.message);
  } catch (e) {
    rethrow;
  }
}
